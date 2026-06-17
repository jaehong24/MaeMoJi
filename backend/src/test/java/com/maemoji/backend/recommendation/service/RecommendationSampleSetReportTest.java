package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
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
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class RecommendationSampleSetReportTest {

    private static final List<String> SAMPLE_SYMBOLS = List.of(
            "NVDA", "GOOGL", "AMZN", "META", "NFLX",
            "AAPL", "MSFT", "COST", "MCD", "PG",
            "TSLA", "AVGO", "PLTR", "ARM",
            "CAT", "DELL", "JPM", "GS", "HD",
            "AMD", "ADBE", "CRM", "ORCL", "NOW",
            "UNH", "XOM", "KO", "NEE", "WMT",
            "QQQ", "SPY", "VOO", "SCHD", "SOXX"
    );

    @Test
    void generatesCurrentSampleSetComparisonReport() throws Exception {
        final RecommendationTuningProperties tuningProperties = new RecommendationTuningProperties();
        final RecommendationService recommendationService = new RecommendationService(
                mock(RecommendationMapper.class),
                new ObjectMapper(),
                mock(NewsSentimentService.class),
                new RecommendationScoreCalculator(tuningProperties),
                mock(StockPriceSnapshotMapper.class),
                mock(StockPriceSnapshotBatchService.class),
                tuningProperties,
                mock(PlatformTransactionManager.class)
        );

        final DatabaseConfig databaseConfig = loadDatabaseConfig();
        final Class<?> priceSnapshotClass = findPriceSnapshotClass();
        final Constructor<?> constructor = priceSnapshotClass.getDeclaredConstructors()[0];
        constructor.setAccessible(true);

        final List<SampleScoreRow> rows = new ArrayList<>();
        final List<String> missingSymbols = new ArrayList<>();
        try (Connection connection = DriverManager.getConnection(
                databaseConfig.url(),
                databaseConfig.username(),
                databaseConfig.password()
        )) {
            for (String symbol : SAMPLE_SYMBOLS) {
                final SnapshotRow snapshotRow = fetchLatestSnapshot(connection, symbol);
                if (snapshotRow == null) {
                    missingSymbols.add(symbol);
                    continue;
                }

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
                final Integer valuationScore = assessment == null
                        ? null
                        : (Integer) ReflectionTestUtils.invokeMethod(assessment, "valuationScore");
                final Integer qualityOfGrowthScore = (Integer) ReflectionTestUtils.invokeMethod(
                        recommendationService,
                        "resolveQualityOfGrowthScore",
                        assessment
                );

                final int companyTotalScore = weightedAverage(
                        priceMomentumScore, tuningProperties.getFactorWeights().getPriceMomentum(),
                        priceStabilityScore, tuningProperties.getFactorWeights().getPriceStability(),
                        fundamentalQualityScore, tuningProperties.getFactorWeights().getFundamentalQuality(),
                        valuationScore, tuningProperties.getFactorWeights().getValuation(),
                        qualityOfGrowthScore, tuningProperties.getFactorWeights().getQualityOfGrowth()
                );

                rows.add(new SampleScoreRow(
                        symbol,
                        snapshotRow.snapshotDate(),
                        snapshotRow.currentPrice(),
                        priceMomentumScore,
                        priceStabilityScore,
                        fundamentalQualityScore,
                        valuationScore,
                        qualityOfGrowthScore,
                        companyTotalScore
                ));
            }
        }

        assertThat(rows).isNotEmpty();
        writeMarkdownReport(rows, missingSymbols, tuningProperties);
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

    private SnapshotRow fetchLatestSnapshot(Connection connection, String symbol) throws Exception {
        final String sql = """
                select
                    s.symbol,
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
                limit 1
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, symbol);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                return new SnapshotRow(
                        resultSet.getString("symbol"),
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
                );
            }
        }
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

    private int weightedAverage(Object... valuesAndWeights) {
        double weightedSum = 0;
        int totalWeight = 0;
        for (int index = 0; index < valuesAndWeights.length; index += 2) {
            final Integer score = (Integer) valuesAndWeights[index];
            final Integer weight = (Integer) valuesAndWeights[index + 1];
            if (score == null || weight == null || weight <= 0) {
                continue;
            }
            weightedSum += score * weight;
            totalWeight += weight;
        }
        if (totalWeight == 0) {
            return 0;
        }
        return (int) Math.round(weightedSum / totalWeight);
    }

    private void writeMarkdownReport(
            List<SampleScoreRow> rows,
            List<String> missingSymbols,
            RecommendationTuningProperties tuningProperties
    ) throws IOException {
        final List<SampleScoreRow> sortedRows = rows.stream()
                .sorted((left, right) -> Integer.compare(right.companyTotalScore(), left.companyTotalScore()))
                .toList();

        final StringBuilder markdown = new StringBuilder();
        markdown.append("# MaeMoJi V4 현재 샘플셋 점수표").append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- 생성 시각: ")
                .append(OffsetDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss xxx")))
                .append(System.lineSeparator());
        markdown.append("- 기준: 최신 `stock_price_snapshots` 1건 기준").append(System.lineSeparator());
        markdown.append("- 총점 의미: 뉴스/사용자 보정 전, 종목 고유 팩터만 반영한 비교용 점수").append(System.lineSeparator());
        markdown.append("- 반영 가중치: ")
                .append("가격 흐름 ").append(tuningProperties.getFactorWeights().getPriceMomentum()).append(", ")
                .append("가격 안정성 ").append(tuningProperties.getFactorWeights().getPriceStability()).append(", ")
                .append("기업 체력 ").append(tuningProperties.getFactorWeights().getFundamentalQuality()).append(", ")
                .append("밸류에이션 ").append(tuningProperties.getFactorWeights().getValuation()).append(", ")
                .append("성장의 질 ").append(tuningProperties.getFactorWeights().getQualityOfGrowth())
                .append(System.lineSeparator()).append(System.lineSeparator());

        markdown.append("## 점수 분포 요약").append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- 종목 기준 총점 범위: ")
                .append(formatRange(sortedRows.stream().map(SampleScoreRow::companyTotalScore).toList()))
                .append(System.lineSeparator());
        markdown.append("- 기업 체력 범위: ")
                .append(formatRange(sortedRows.stream().map(SampleScoreRow::fundamentalQualityScore).toList()))
                .append(System.lineSeparator());
        markdown.append("- 밸류에이션 범위: ")
                .append(formatRange(sortedRows.stream().map(SampleScoreRow::valuationScore).toList()))
                .append(System.lineSeparator());
        markdown.append("- 성장의 질 범위: ")
                .append(formatRange(sortedRows.stream().map(SampleScoreRow::qualityOfGrowthScore).toList()))
                .append(System.lineSeparator());
        markdown.append("- 가격 흐름 데이터 존재 종목 수: ")
                .append(sortedRows.stream().filter(row -> row.priceMomentumScore() != null).count())
                .append(" / ")
                .append(sortedRows.size())
                .append(System.lineSeparator());
        if (!missingSymbols.isEmpty()) {
            markdown.append("- 스냅샷 미존재 종목: ")
                    .append(String.join(", ", missingSymbols))
                    .append(System.lineSeparator());
        }
        markdown.append(System.lineSeparator());

        markdown.append("| 종목 | 스냅샷일 | 현재가 | 가격흐름 | 가격안정성 | 기업체력 | 밸류에이션 | 성장의 질 | 종목 기준 총점 |")
                .append(System.lineSeparator());
        markdown.append("|---|---:|---:|---:|---:|---:|---:|---:|---:|")
                .append(System.lineSeparator());

        for (SampleScoreRow row : sortedRows) {
            markdown.append("| ")
                    .append(row.symbol()).append(" | ")
                    .append(row.snapshotDate()).append(" | ")
                    .append(formatNullableDecimal(row.currentPrice(), 2)).append(" | ")
                    .append(formatNullableInteger(row.priceMomentumScore())).append(" | ")
                    .append(formatNullableInteger(row.priceStabilityScore())).append(" | ")
                    .append(formatNullableInteger(row.fundamentalQualityScore())).append(" | ")
                    .append(formatNullableInteger(row.valuationScore())).append(" | ")
                    .append(formatNullableInteger(row.qualityOfGrowthScore())).append(" | ")
                    .append(row.companyTotalScore()).append(" |")
                    .append(System.lineSeparator());
        }

        markdown.append(System.lineSeparator())
                .append("## 해석 포인트").append(System.lineSeparator()).append(System.lineSeparator())
                .append("- `기업 체력`은 수익성, 안정성, 현금흐름, 효율 중심 점수입니다.").append(System.lineSeparator())
                .append("- `밸류에이션`은 현재 가격 부담을 별도 분리한 점수입니다.").append(System.lineSeparator())
                .append("- `성장의 질`은 매출 성장률뿐 아니라 EPS, 마진, 현금흐름 품질을 함께 봅니다.").append(System.lineSeparator());

        final Path outputPath = Path.of("..", "docs", "recommendation", "v4-sample-set-current-report.md").normalize();
        Files.createDirectories(outputPath.getParent());
        Files.writeString(outputPath, markdown.toString(), StandardCharsets.UTF_8);
    }

    private String formatNullableInteger(Integer value) {
        return value == null ? "-" : Integer.toString(value);
    }

    private String formatNullableDecimal(Double value, int scale) {
        if (value == null) {
            return "-";
        }
        return String.format(Locale.US, "%." + scale + "f", value);
    }

    private String formatRange(List<Integer> values) {
        final List<Integer> nonNullValues = values.stream()
                .filter(value -> value != null)
                .sorted()
                .toList();
        if (nonNullValues.isEmpty()) {
            return "-";
        }
        return nonNullValues.get(0) + " ~ " + nonNullValues.get(nonNullValues.size() - 1);
    }

    private record DatabaseConfig(
            String url,
            String username,
            String password
    ) {
    }

    private record SnapshotRow(
            String symbol,
            java.time.LocalDate snapshotDate,
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

    private record SampleScoreRow(
            String symbol,
            java.time.LocalDate snapshotDate,
            Double currentPrice,
            Integer priceMomentumScore,
            Integer priceStabilityScore,
            Integer fundamentalQualityScore,
            Integer valuationScore,
            Integer qualityOfGrowthScore,
            int companyTotalScore
    ) {
    }
}
