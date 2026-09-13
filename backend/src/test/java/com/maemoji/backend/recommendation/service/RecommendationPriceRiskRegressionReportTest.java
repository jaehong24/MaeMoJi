package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.portfolioinsight.domain.RecommendationTrendRow;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import com.maemoji.backend.portfolioinsight.service.PushNotificationDispatchService;
import com.maemoji.backend.portfolioinsight.service.WeeklyDigestNotificationService;
import com.maemoji.backend.portfolioinsight.service.WeeklyReportService;
import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import com.maemoji.backend.recommendation.domain.RecommendationTarget;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.PlatformTransactionManager;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class RecommendationPriceRiskRegressionReportTest {

    private static final List<String> TARGET_SYMBOLS = List.of(
            "AMD", "CRM", "NOW", "SNOW", "NET", "SHOP", "TSLA",
            "MSFT", "META", "NVDA", "AMZN", "COST"
    );

    private final RecommendationTuningProperties tuningProperties =
            new RecommendationTuningProperties();

    @Test
    void generatesPriceRiskRegressionReportForCoreOperatingSamples() throws Exception {
        final RecommendationScoreCalculator scoreCalculator = new RecommendationScoreCalculator(tuningProperties);
        final RecommendationService recommendationService = new RecommendationService(
                mock(RecommendationMapper.class),
                new ObjectMapper(),
                mock(NewsSentimentService.class),
                scoreCalculator,
                mock(StockPriceSnapshotMapper.class),
                mock(StockPriceSnapshotBatchService.class),
                tuningProperties,
                mock(PlatformTransactionManager.class)
        );
        final WeeklyReportService weeklyReportService = new WeeklyReportService(
                mock(PortfolioInsightMapper.class),
                mock(PushNotificationDispatchService.class),
                mock(WeeklyDigestNotificationService.class)
        );

        final DatabaseConfig databaseConfig = loadDatabaseConfig();
        final Class<?> priceSnapshotClass = findPriceSnapshotClass();
        final Constructor<?> constructor = priceSnapshotClass.getDeclaredConstructors()[0];
        constructor.setAccessible(true);

        final List<RegressionRow> rows = new ArrayList<>();
        final List<String> missingSymbols = new ArrayList<>();

        try (Connection connection = DriverManager.getConnection(
                databaseConfig.url(),
                databaseConfig.username(),
                databaseConfig.password()
        )) {
            for (String symbol : TARGET_SYMBOLS) {
                final List<SnapshotRow> snapshots = fetchLatestTwoSnapshots(connection, symbol);
                if (snapshots.isEmpty()) {
                    missingSymbols.add(symbol);
                    continue;
                }

                final SnapshotRow currentSnapshot = snapshots.get(0);
                final SnapshotRow previousSnapshot = snapshots.size() > 1 ? snapshots.get(1) : null;

                final Evaluation currentEvaluation = evaluateSnapshot(
                        recommendationService,
                        scoreCalculator,
                        constructor,
                        currentSnapshot
                );
                final Evaluation previousEvaluation = previousSnapshot == null
                        ? null
                        : evaluateSnapshot(
                        recommendationService,
                        scoreCalculator,
                        constructor,
                        previousSnapshot
                );

                final String changeType = resolveChangeType(
                        weeklyReportService,
                        symbol,
                        currentEvaluation,
                        previousEvaluation
                );
                final boolean supplementalPriceRisk = resolveSupplementalPriceRisk(
                        weeklyReportService,
                        symbol,
                        currentEvaluation,
                        previousEvaluation
                );

                rows.add(new RegressionRow(
                        symbol,
                        currentSnapshot.snapshotDate(),
                        previousSnapshot == null ? null : previousSnapshot.snapshotDate(),
                        currentEvaluation.finalScore(),
                        previousEvaluation == null ? null : previousEvaluation.finalScore(),
                        currentEvaluation.status(),
                        previousEvaluation == null ? null : previousEvaluation.status(),
                        currentEvaluation.priceMomentumScore(),
                        previousEvaluation == null ? null : previousEvaluation.priceMomentumScore(),
                        currentEvaluation.priceStabilityScore(),
                        previousEvaluation == null ? null : previousEvaluation.priceStabilityScore(),
                        changeType,
                        supplementalPriceRisk,
                        "PRICE_RISK".equals(changeType),
                        currentEvaluation.reason(),
                        buildBoundaryRelaxationNote(currentEvaluation, previousEvaluation)
                ));
            }
        }

        assertThat(rows).isNotEmpty();
        writeMarkdownReport(rows, missingSymbols);
    }

    private Evaluation evaluateSnapshot(
            RecommendationService recommendationService,
            RecommendationScoreCalculator scoreCalculator,
            Constructor<?> constructor,
            SnapshotRow snapshotRow
    ) throws Exception {
        final Object priceSnapshot = buildPriceSnapshot(constructor, snapshotRow);
        final Object assessment = ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveFundamentalQualityAssessment",
                priceSnapshot
        );
        final Integer priceMomentumScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolvePriceMomentumScore",
                priceSnapshot
        );
        final Integer priceStabilityScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolvePriceStabilityScore",
                priceSnapshot
        );
        final Integer fundamentalQualityScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveFundamentalCoreScore",
                assessment
        );
        final Integer profitabilityFactorScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveProfitabilityFactorScore",
                assessment
        );
        final Integer valuationScore = assessment == null
                ? null
                : (Integer) ReflectionTestUtils.invokeMethod(assessment, "valuationScore");
        final Integer qualityOfGrowthScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveQualityOfGrowthScore",
                assessment
        );

        final RecommendationTarget reportTarget = new RecommendationTarget();
        reportTarget.setTicker(snapshotRow.symbol());
        reportTarget.setSector(snapshotRow.sector());
        reportTarget.setIndustry(snapshotRow.industry());
        final Integer crossFactorAdjustment = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveCrossFactorAdjustment",
                reportTarget,
                priceSnapshot,
                new NewsSentimentService.NewsSentimentResult(
                        0,
                        "NEUTRAL",
                        "",
                        List.of(),
                        "report",
                        0,
                        false,
                        "NONE",
                        70,
                        false,
                        false
                ),
                priceMomentumScore,
                priceStabilityScore,
                fundamentalQualityScore,
                profitabilityFactorScore,
                valuationScore,
                qualityOfGrowthScore
        );

        final RecommendationScoreCalculator.V4ScoreResult result = scoreCalculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        priceMomentumScore,
                        tuningProperties.getFactorWeights().getPriceMomentum(),
                        priceStabilityScore,
                        tuningProperties.getFactorWeights().getPriceStability(),
                        null,
                        0,
                        fundamentalQualityScore,
                        tuningProperties.getFactorWeights().getFundamentalQuality(),
                        valuationScore,
                        tuningProperties.getFactorWeights().getValuation(),
                        qualityOfGrowthScore,
                        tuningProperties.getFactorWeights().getQualityOfGrowth(),
                        60,
                        tuningProperties.getFactorWeights().getUserFit(),
                        crossFactorAdjustment == null ? 0 : crossFactorAdjustment,
                        0,
                        "BALANCED",
                        false,
                        false,
                        78
                )
        );

        final String reason = buildReason(
                result,
                priceMomentumScore,
                priceStabilityScore,
                valuationScore,
                qualityOfGrowthScore
        );

        return new Evaluation(
                result.finalScore(),
                result.recommendationStatus(),
                priceMomentumScore,
                priceStabilityScore,
                reason
        );
    }

    private String resolveChangeType(
            WeeklyReportService weeklyReportService,
            String symbol,
            Evaluation current,
            Evaluation previous
    ) throws Exception {
        if (previous == null) {
            return "NEW_ENTRY";
        }
        final RecommendationTrendRow currentRow = new RecommendationTrendRow();
        currentRow.setPortfolioItemId(1L);
        currentRow.setCompanyName(symbol);
        currentRow.setRecommendationStatus(current.status());
        currentRow.setEngineScore(current.finalScore());
        currentRow.setNewsScore(50);
        currentRow.setPriceMomentumScore(current.priceMomentumScore());
        currentRow.setPriceStabilityScore(current.priceStabilityScore());
        currentRow.setFundamentalQualityScore(70);

        final RecommendationTrendRow previousRow = new RecommendationTrendRow();
        previousRow.setPortfolioItemId(1L);
        previousRow.setCompanyName(symbol);
        previousRow.setRecommendationStatus(previous.status());
        previousRow.setEngineScore(previous.finalScore());
        previousRow.setNewsScore(50);
        previousRow.setPriceMomentumScore(previous.priceMomentumScore());
        previousRow.setPriceStabilityScore(previous.priceStabilityScore());
        previousRow.setFundamentalQualityScore(70);

        final Object trend = ReflectionTestUtils.invokeMethod(
                weeklyReportService,
                "buildTrend",
                currentRow,
                previousRow
        );
        final var changeTypeMethod = trend.getClass().getDeclaredMethod("changeType");
        changeTypeMethod.setAccessible(true);
        return (String) changeTypeMethod.invoke(trend);
    }

    private boolean resolveSupplementalPriceRisk(
            WeeklyReportService weeklyReportService,
            String symbol,
            Evaluation current,
            Evaluation previous
    ) {
        if (previous == null) {
            return false;
        }
        final RecommendationTrendRow currentRow = new RecommendationTrendRow();
        currentRow.setPortfolioItemId(1L);
        currentRow.setCompanyName(symbol);
        currentRow.setRecommendationStatus(current.status());
        currentRow.setEngineScore(current.finalScore());
        currentRow.setNewsScore(50);
        currentRow.setPriceMomentumScore(current.priceMomentumScore());
        currentRow.setPriceStabilityScore(current.priceStabilityScore());
        currentRow.setFundamentalQualityScore(70);

        final int momentumDelta = current.priceMomentumScore() == null || previous.priceMomentumScore() == null
                ? 0
                : current.priceMomentumScore() - previous.priceMomentumScore();
        final int stabilityDelta = current.priceStabilityScore() == null || previous.priceStabilityScore() == null
                ? 0
                : current.priceStabilityScore() - previous.priceStabilityScore();

        final Boolean result = (Boolean) ReflectionTestUtils.invokeMethod(
                weeklyReportService,
                "hasSupplementalPriceRiskSignal",
                currentRow,
                momentumDelta,
                stabilityDelta
        );
        return Boolean.TRUE.equals(result);
    }

    private String buildReason(
            RecommendationScoreCalculator.V4ScoreResult result,
            Integer priceMomentumScore,
            Integer priceStabilityScore,
            Integer valuationScore,
            Integer qualityOfGrowthScore
    ) {
        if ("INCREASE".equals(result.recommendationStatus())) {
            return "핵심 팩터가 고르게 강한 증액 우세";
        }
        if ("STOP".equals(result.recommendationStatus())) {
            if (valuationScore != null && valuationScore <= 45) {
                return "기업 체력은 버티지만 가격 부담이 큰 가격 부담 중단";
            }
            if (priceMomentumScore != null
                    && priceMomentumScore <= 42
                    && priceStabilityScore != null
                    && priceStabilityScore <= 45) {
                return "흐름과 안정성이 모두 약한 변동성 중단";
            }
            if (qualityOfGrowthScore != null && qualityOfGrowthScore <= 58) {
                return "성장 재가속 신호가 약한 성장 둔화 중단";
            }
            return "가격 부담 또는 변동성 확대가 반영된 중단";
        }
        if ("REDUCE".equals(result.recommendationStatus())) {
            if (valuationScore != null && valuationScore <= 45) {
                return "기업 체력은 받쳐주지만 가격 부담이 큰 가격 부담 감액";
            }
            if (priceMomentumScore != null
                    && priceMomentumScore <= 42
                    && priceStabilityScore != null
                    && priceStabilityScore <= 45) {
                return "흐름과 안정성이 모두 약한 변동성 감액";
            }
            if (qualityOfGrowthScore != null && qualityOfGrowthScore <= 58) {
                return "가격은 무난해도 성장 질이 약한 성장 둔화 감액";
            }
            return "가격 부담 또는 변동성 확대가 반영된 감액";
        }
        if (valuationScore != null && valuationScore <= 58) {
            return "기대가 가격에 먼저 반영된 가격 반영 유지";
        }
        if (priceMomentumScore != null
                && priceMomentumScore >= 70
                && priceStabilityScore != null
                && priceStabilityScore >= 74) {
            return "핵심 팩터는 충분하지만 마지막 가격 여유를 더 확인하는 증액 직전 유지";
        }
        if (priceMomentumScore != null
                && priceMomentumScore >= 36
                && priceMomentumScore <= 60
                && priceStabilityScore != null
                && priceStabilityScore <= 55) {
            return "기업 체력은 강하지만 최근 가격 흔들림이 남은 증액 직전 유지";
        }
        if (qualityOfGrowthScore != null && qualityOfGrowthScore <= 60) {
            return "방어력은 괜찮지만 성장 탄력이 약한 성장 확인 유지";
        }
        if (priceMomentumScore != null
                && priceMomentumScore <= 46
                && qualityOfGrowthScore != null
                && qualityOfGrowthScore <= 58
                && priceStabilityScore != null
                && priceStabilityScore >= 58) {
            return "감액 직전이지만 방어력은 남아 있는 감액 직전 유지";
        }
        return "여러 팩터가 비교적 잘 버티지만 한 단계 더 확인이 필요한 성장 확인 유지";
    }

    private String buildBoundaryRelaxationNote(Evaluation current, Evaluation previous) {
        if (previous == null) {
            return "-";
        }

        final String currentStatus = blankDash(current.status());
        final String previousStatus = blankDash(previous.status());
        final boolean wasStop = "STOP".equals(previousStatus);
        final boolean isStop = "STOP".equals(currentStatus);
        final boolean isReduce = "REDUCE".equals(currentStatus);
        final boolean wasReduce = "REDUCE".equals(previousStatus);

        final int momentumDelta = safeDelta(current.priceMomentumScore(), previous.priceMomentumScore());
        final int stabilityDelta = safeDelta(current.priceStabilityScore(), previous.priceStabilityScore());

        if (isReduce && wasStop) {
            if (stabilityDelta >= 8) {
                return "변동성 완화: 하방 리스크가 전일 대비 줄어 중단에서 감액으로 완화";
            }
            if (momentumDelta >= 8) {
                return "성장 둔화 완화: 가격 흐름 약세가 전일 대비 완화돼 중단에서 감액으로 완화";
            }
            return "가격 부담 완화: 중단 요인이 일부 누그러져 감액 구간으로 완화";
        }

        if (isStop && wasReduce) {
            if (current.priceStabilityScore() != null && current.priceStabilityScore() <= 45 && stabilityDelta <= -6) {
                return "변동성 악화: 하방 리스크가 다시 커져 감액에서 중단으로 강화";
            }
            if (current.priceMomentumScore() != null && current.priceMomentumScore() <= 30 && momentumDelta <= -6) {
                return "성장 둔화 악화: 가격 흐름 약세가 심해져 감액에서 중단으로 강화";
            }
            return "가격 부담 악화: 가격 부담 대비 확신이 더 약해져 감액에서 중단으로 강화";
        }

        if (isStop && wasStop) {
            if (current.priceStabilityScore() != null && current.priceStabilityScore() <= 45) {
                return "변동성 지속: 하방 리스크가 계속 높아 중단 유지";
            }
            if (current.priceMomentumScore() != null && current.priceMomentumScore() <= 30) {
                return "성장 둔화 지속: 흐름 약세가 계속 강해 중단 유지";
            }
            return "가격 부담 지속: 가격 부담이 계속 커 중단 유지";
        }

        if (isReduce && wasReduce) {
            if (current.priceStabilityScore() != null
                    && current.priceStabilityScore() <= 60
                    && stabilityDelta >= 6) {
                return "변동성 완화 중: 흔들림은 줄었지만 아직 감액 구간";
            }
            if (current.priceMomentumScore() != null
                    && current.priceMomentumScore() >= 40
                    && current.priceMomentumScore() <= 55
                    && momentumDelta >= 6) {
                return "성장 둔화 완화 중: 흐름은 나아졌지만 아직 감액 구간";
            }
            if (current.priceMomentumScore() != null
                    && current.priceMomentumScore() >= 38
                    && current.priceStabilityScore() != null
                    && current.priceStabilityScore() >= 60) {
                return "가격 부담 완화 중: 방어력은 나아졌지만 가격 부담이 남아 감액 유지";
            }
        }

        return "-";
    }

    private int safeDelta(Integer current, Integer previous) {
        if (current == null || previous == null) {
            return 0;
        }
        return current - previous;
    }

    private List<SnapshotRow> fetchLatestTwoSnapshots(Connection connection, String symbol) throws Exception {
        final String sql = """
                select
                    s.symbol,
                    s.sector,
                    s.industry,
                    p.snapshot_date,
                    p.current_price,
                    p.change_rate_7d,
                    p.change_rate_30d,
                    p.market_cap,
                    p.per_value,
                    p.eps_ttm,
                    p.revenue_growth_yoy,
                    p.gross_margin_ttm,
                    p.net_margin_ttm,
                    p.operating_margin_ttm,
                    p.roe_ttm,
                    p.roa_ttm,
                    p.roic_ttm,
                    p.debt_to_equity_ttm,
                    p.current_ratio_ttm,
                    p.quick_ratio_ttm,
                    p.asset_turnover_ttm,
                    p.free_cash_flow_yield_ttm,
                    p.operating_cash_flow_ratio_ttm,
                    p.income_quality_ttm
                from stocks s
                join stock_price_snapshots p on p.stock_id = s.id
                where s.symbol = ?
                order by p.snapshot_date desc, p.id desc
                limit 2
                """;

        final List<SnapshotRow> rows = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, symbol);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    rows.add(new SnapshotRow(
                            resultSet.getString("symbol"),
                            resultSet.getString("sector"),
                            resultSet.getString("industry"),
                            resultSet.getDate("snapshot_date").toLocalDate(),
                            getNullableDouble(resultSet, "current_price"),
                            getNullableDouble(resultSet, "change_rate_7d"),
                            getNullableDouble(resultSet, "change_rate_30d"),
                            resultSet.getBigDecimal("market_cap"),
                            resultSet.getBigDecimal("per_value"),
                            resultSet.getBigDecimal("eps_ttm"),
                            resultSet.getBigDecimal("revenue_growth_yoy"),
                            resultSet.getBigDecimal("gross_margin_ttm"),
                            resultSet.getBigDecimal("net_margin_ttm"),
                            resultSet.getBigDecimal("operating_margin_ttm"),
                            resultSet.getBigDecimal("roe_ttm"),
                            resultSet.getBigDecimal("roa_ttm"),
                            resultSet.getBigDecimal("roic_ttm"),
                            resultSet.getBigDecimal("debt_to_equity_ttm"),
                            resultSet.getBigDecimal("current_ratio_ttm"),
                            resultSet.getBigDecimal("quick_ratio_ttm"),
                            resultSet.getBigDecimal("asset_turnover_ttm"),
                            resultSet.getBigDecimal("free_cash_flow_yield_ttm"),
                            resultSet.getBigDecimal("operating_cash_flow_ratio_ttm"),
                            resultSet.getBigDecimal("income_quality_ttm")
                    ));
                }
            }
        }
        return rows;
    }

    private Object buildPriceSnapshot(Constructor<?> constructor, SnapshotRow snapshot) throws Exception {
        final Object[] args = new Object[constructor.getParameterCount()];
        args[0] = snapshot.currentPrice();
        args[1] = snapshot.changeRate7d();
        args[2] = snapshot.changeRate30d();
        args[3] = snapshot.marketCap();
        args[4] = snapshot.perValue();
        args[5] = snapshot.epsTtm();
        args[6] = snapshot.revenueGrowthYoy();
        args[7] = snapshot.grossMarginTtm();
        args[8] = snapshot.netMarginTtm();
        args[9] = snapshot.operatingMarginTtm();
        args[10] = snapshot.roeTtm();
        args[11] = snapshot.roaTtm();
        args[12] = snapshot.roicTtm();
        args[13] = snapshot.debtToEquityTtm();
        args[14] = snapshot.currentRatioTtm();
        args[15] = snapshot.quickRatioTtm();
        args[16] = snapshot.assetTurnoverTtm();
        args[17] = snapshot.freeCashFlowYieldTtm();
        args[18] = snapshot.operatingCashFlowRatioTtm();
        args[19] = snapshot.incomeQualityTtm();
        return constructor.newInstance(args);
    }

    private Double getNullableDouble(ResultSet resultSet, String columnName) throws Exception {
        final double value = resultSet.getDouble(columnName);
        return resultSet.wasNull() ? null : value;
    }

    private DatabaseConfig loadDatabaseConfig() throws IOException {
        final Map<String, String> values = new LinkedHashMap<>(System.getenv());
        final Path envPath = Path.of("..", ".env").normalize();
        if (Files.exists(envPath)) {
            for (String line : Files.readAllLines(envPath, StandardCharsets.UTF_8)) {
                final String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#") || !trimmed.contains("=")) {
                    continue;
                }
                final int delimiterIndex = trimmed.indexOf('=');
                final String key = trimmed.substring(0, delimiterIndex).trim();
                final String value = trimmed.substring(delimiterIndex + 1).trim();
                values.putIfAbsent(key, value);
            }
        }

        final String url = firstNonBlank(values, "SPRING_DATASOURCE_URL", "DATABASE_URL", "NEON_DATABASE_URL");
        final String username = firstNonBlank(values, "SPRING_DATASOURCE_USERNAME");
        final String password = firstNonBlank(values, "SPRING_DATASOURCE_PASSWORD");

        assertThat(url).as("database url").isNotBlank();
        assertThat(username).as("database username").isNotBlank();
        assertThat(password).as("database password").isNotBlank();
        return new DatabaseConfig(url, username, password);
    }

    private String firstNonBlank(Map<String, String> values, String... keys) {
        for (String key : keys) {
            final String value = values.get(key);
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }

    private Class<?> findPriceSnapshotClass() {
        for (Class<?> nestedClass : RecommendationService.class.getDeclaredClasses()) {
            if ("PriceSnapshot".equals(nestedClass.getSimpleName())) {
                return nestedClass;
            }
        }
        throw new IllegalStateException("PriceSnapshot record class not found");
    }

    private void writeMarkdownReport(List<RegressionRow> rows, List<String> missingSymbols) throws IOException {
        final StringBuilder markdown = new StringBuilder();
        markdown.append("# 가격 흔들림 2차 회귀표").append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- 생성 시각: ")
                .append(OffsetDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss xxx")))
                .append(System.lineSeparator());
        markdown.append("- 기준 종목: ")
                .append(String.join(", ", TARGET_SYMBOLS))
                .append(System.lineSeparator());
        markdown.append("- 해석: `알림 후보`가 `예`이면 현재 운영 로직상 `가격 흔들림` 즉시 알림 후보입니다.")
                .append(System.lineSeparator());
        markdown.append("- 해석: `보조 가격리스크`가 `예`이면 주된 변화는 다른 타입이어도 가격 흔들림 신호가 함께 있었던 케이스입니다.")
                .append(System.lineSeparator())
                .append(System.lineSeparator());

        markdown.append("| 종목 | 현재일 | 이전일 | 현재점수 | 이전점수 | 현재상태 | 이전상태 | 현재흐름 | 이전흐름 | 현재안정성 | 이전안정성 | changeType | 보조 가격리스크 | 알림 후보 | 메모 | 완화 이유 |")
                .append(System.lineSeparator());
        markdown.append("|---|---|---|---:|---:|---|---|---:|---:|---:|---:|---|---|---|---|---|")
                .append(System.lineSeparator());

        for (RegressionRow row : rows) {
            markdown.append("| ")
                    .append(row.symbol()).append(" | ")
                    .append(row.currentDate()).append(" | ")
                    .append(formatNullableDate(row.previousDate())).append(" | ")
                    .append(row.currentFinalScore()).append(" | ")
                    .append(formatNullableInteger(row.previousFinalScore())).append(" | ")
                    .append(row.currentStatus()).append(" | ")
                    .append(blankDash(row.previousStatus())).append(" | ")
                    .append(formatNullableInteger(row.currentMomentum())).append(" | ")
                    .append(formatNullableInteger(row.previousMomentum())).append(" | ")
                    .append(formatNullableInteger(row.currentStability())).append(" | ")
                    .append(formatNullableInteger(row.previousStability())).append(" | ")
                    .append(row.changeType()).append(" | ")
                    .append(row.supplementalPriceRisk() ? "예" : "아니오").append(" | ")
                    .append(row.priceRiskAlert() ? "예" : "아니오").append(" | ")
                    .append(row.note()).append(" | ")
                    .append(row.relaxationNote()).append(" |")
                    .append(System.lineSeparator());
        }

        if (!missingSymbols.isEmpty()) {
            markdown.append(System.lineSeparator())
                    .append("- 스냅샷 부족 종목: ")
                    .append(String.join(", ", missingSymbols))
                    .append(System.lineSeparator());
        }

        final Path outputPath = Path.of("..", "docs", "recommendation", "v4-price-risk-regression-report.md").normalize();
        Files.createDirectories(outputPath.getParent());
        Files.writeString(outputPath, markdown.toString(), StandardCharsets.UTF_8);
    }

    private String formatNullableDate(LocalDate value) {
        return value == null ? "-" : value.toString();
    }

    private String formatNullableInteger(Integer value) {
        return value == null ? "-" : Integer.toString(value);
    }

    private String blankDash(String value) {
        return value == null || value.isBlank() ? "-" : value;
    }

    private record DatabaseConfig(
            String url,
            String username,
            String password
    ) {
    }

    private record SnapshotRow(
            String symbol,
            String sector,
            String industry,
            LocalDate snapshotDate,
            Double currentPrice,
            Double changeRate7d,
            Double changeRate30d,
            BigDecimal marketCap,
            BigDecimal perValue,
            BigDecimal epsTtm,
            BigDecimal revenueGrowthYoy,
            BigDecimal grossMarginTtm,
            BigDecimal netMarginTtm,
            BigDecimal operatingMarginTtm,
            BigDecimal roeTtm,
            BigDecimal roaTtm,
            BigDecimal roicTtm,
            BigDecimal debtToEquityTtm,
            BigDecimal currentRatioTtm,
            BigDecimal quickRatioTtm,
            BigDecimal assetTurnoverTtm,
            BigDecimal freeCashFlowYieldTtm,
            BigDecimal operatingCashFlowRatioTtm,
            BigDecimal incomeQualityTtm
    ) {
    }

    private record Evaluation(
            int finalScore,
            String status,
            Integer priceMomentumScore,
            Integer priceStabilityScore,
            String reason
    ) {
    }

    private record RegressionRow(
            String symbol,
            LocalDate currentDate,
            LocalDate previousDate,
            int currentFinalScore,
            Integer previousFinalScore,
            String currentStatus,
            String previousStatus,
            Integer currentMomentum,
            Integer previousMomentum,
            Integer currentStability,
            Integer previousStability,
            String changeType,
            boolean supplementalPriceRisk,
            boolean priceRiskAlert,
            String note,
            String relaxationNote
    ) {
    }
}
