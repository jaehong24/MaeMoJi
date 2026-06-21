package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import com.maemoji.backend.recommendation.domain.RecommendationRecord;
import com.maemoji.backend.recommendation.domain.RecommendationTarget;
import com.maemoji.backend.recommendation.dto.RecommendationResponse;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.PlatformTransactionManager;

import java.lang.reflect.Constructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RecommendationServiceQueryFlowTest {

    private final RecommendationMapper recommendationMapper = mock(RecommendationMapper.class);
    private final NewsSentimentService newsSentimentService = mock(NewsSentimentService.class);
    private final RecommendationScoreCalculator scoreCalculator = mock(RecommendationScoreCalculator.class);
    private final StockPriceSnapshotMapper stockPriceSnapshotMapper = mock(StockPriceSnapshotMapper.class);
    private final StockPriceSnapshotBatchService stockPriceSnapshotBatchService = mock(StockPriceSnapshotBatchService.class);
    private final RecommendationTuningProperties tuningProperties = new RecommendationTuningProperties();
    private final RecommendationService recommendationService = new RecommendationService(
            recommendationMapper,
            new ObjectMapper(),
            newsSentimentService,
            scoreCalculator,
            stockPriceSnapshotMapper,
            stockPriceSnapshotBatchService,
            tuningProperties,
            mock(PlatformTransactionManager.class)
    );

    @Test
    void getLatestRecommendationsReturnsStoredRecordsWithoutRecomputing() {
        final RecommendationTarget target = createTarget(101L, 1001L, 2001L);
        final RecommendationRecord staleRecord = createRecord(101L, 1001L, 2001L, LocalDate.now().minusDays(1));

        when(recommendationMapper.findActiveRecommendationTargetsByUserId(1L)).thenReturn(List.of(target));
        when(recommendationMapper.findLatestRecommendationsByUserId(1L)).thenReturn(List.of(staleRecord));
        when(recommendationMapper.findRecommendationEvidenceByRecommendationId(9001L)).thenReturn(List.of());
        when(recommendationMapper.findLatestNewsAnalysisByStockId(2001L)).thenReturn(List.of());

        final List<RecommendationResponse> responses = recommendationService.getLatestRecommendations(1L);

        assertThat(responses).hasSize(1);
        assertThat(responses.get(0).recommendationId()).isEqualTo(9001L);
        assertThat(responses.get(0).portfolioItemId()).isEqualTo(1001L);
        verify(recommendationMapper, never())
                .findActiveRecommendationTargetByUserIdAndPortfolioItemId(anyLong(), anyLong());
    }

    @Test
    void getLatestRecommendationsForStoredEtfForcesPendingView() {
        final RecommendationTarget target = createTarget(111L, 1011L, 2011L);
        final RecommendationRecord etfRecord = createRecord(111L, 1011L, 2011L, LocalDate.now().minusDays(1));
        etfRecord.setAssetType("ETF");
        etfRecord.setFormulaVersion("SCORE_V4_MULTI_FACTOR");
        etfRecord.setEngineVersion("ENGINE_V4");
        etfRecord.setRecommendationStatus("INCREASE");

        when(recommendationMapper.findActiveRecommendationTargetsByUserId(1L)).thenReturn(List.of(target));
        when(recommendationMapper.findLatestRecommendationsByUserId(1L)).thenReturn(List.of(etfRecord));
        when(recommendationMapper.findRecommendationEvidenceByRecommendationId(9001L)).thenReturn(List.of());
        when(recommendationMapper.findRecommendationFactorDetailsByRecommendationId(9001L)).thenReturn(List.of());
        when(recommendationMapper.findLatestNewsAnalysisByStockId(2011L)).thenReturn(List.of());

        final List<RecommendationResponse> responses = recommendationService.getLatestRecommendations(1L);

        assertThat(responses).hasSize(1);
        assertThat(responses.get(0).assetType()).isEqualTo("ETF");
        assertThat(responses.get(0).engineVersion()).isEqualTo("ETF_PENDING");
        assertThat(responses.get(0).calculation().formulaVersion()).isEqualTo("ETF_PENDING");
        assertThat(responses.get(0).analysisStageMessage()).isEqualTo("ETF 전용 분석은 준비 중입니다.");
    }

    @Test
    void getOptimizedRecommendationDetailReturnsPendingWhenNoStoredRecommendationExists() {
        final RecommendationTarget target = createTarget(202L, 1002L, 2002L);

        when(recommendationMapper.findLatestRecommendationByUserIdAndPortfolioItemId(1L, 1002L)).thenReturn(null);
        when(recommendationMapper.findActiveRecommendationTargetByUserIdAndPortfolioItemId(1L, 1002L))
                .thenReturn(target);

        final RecommendationResponse response =
                recommendationService.getOptimizedRecommendationDetail(1L, 1002L);

        assertThat(response.recommendationId()).isNull();
        assertThat(response.portfolioItemId()).isEqualTo(1002L);
        assertThat(response.engineVersion()).isEqualTo("PENDING");
        verify(recommendationMapper, never()).findRecommendationEvidenceByRecommendationId(anyLong());
    }

    @Test
    void buildAiCommentReturnsIncreaseMessageForIncreaseStatus() {
        final RecommendationTarget target = createTarget(303L, 1003L, 2003L);

        final String comment = (String) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "buildAiComment",
                target,
                "INCREASE",
                79,
                null,
                new NewsSentimentService.NewsSentimentResult(
                        18,
                        "POSITIVE",
                        "뉴스는 중립 이상입니다.",
                        List.of(),
                        "gemini",
                        18,
                        false,
                        "NONE",
                        80,
                        false,
                        false
                ),
                null
        );

        assertThat(comment).contains("더 모아");
        assertThat(comment).doesNotContain("유지");
    }

    @Test
    void normalizeRecommendationNoteFallsBackWhenIncreaseContainsMaintainTone() {
        final String note = (String) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "normalizeRecommendationNote",
                "INCREASE",
                "현재는 기존 금액을 유지하는 것이 좋습니다."
        );

        assertThat(note).contains("더 모아가는");
        assertThat(note).doesNotContain("유지하는 것이 좋습니다");
    }

    @Test
    void resolvePriceMomentumScorePenalizesOverheatedRunMoreThanHealthyUptrend() throws Exception {
        final Integer healthyScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolvePriceMomentumScore",
                createPriceSnapshot(150.0, 2.2, 9.0)
        );
        final Integer overheatedScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolvePriceMomentumScore",
                createPriceSnapshot(150.0, 11.5, 34.0)
        );

        assertThat(healthyScore).isNotNull();
        assertThat(overheatedScore).isNotNull();
        assertThat(overheatedScore).isLessThan(healthyScore);
    }

    @Test
    void resolvePriceStabilityScoreRewardsCalmTrendMoreThanViolentSwing() throws Exception {
        final Integer calmScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolvePriceStabilityScore",
                createPriceSnapshot(220.0, 1.4, 6.5)
        );
        final Integer unstableScore = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolvePriceStabilityScore",
                createPriceSnapshot(220.0, 12.0, 33.0)
        );

        assertThat(calmScore).isNotNull();
        assertThat(unstableScore).isNotNull();
        assertThat(calmScore).isGreaterThan(unstableScore);
    }

    @Test
    void buildFundamentalEvidenceBodyExplainsProfitabilityAndBalanceSheetSeparately() {
        final String factorRawJson = """
                {
                  "profitabilityFactorScore": 88,
                  "balanceSheetFactorScore": 42,
                  "operatingMarginBand": "STRONG",
                  "debtToEquityBand": "EXCESSIVE"
                }
                """;

        final String body = (String) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "buildFundamentalEvidenceBody",
                "기업 체력 요약입니다.",
                72,
                14,
                factorRawJson
        );

        assertThat(body).contains("수익성은 매우 강한 편");
        assertThat(body).contains("재무건전성은 약한 편");
    }

    private RecommendationTarget createTarget(Long userId, Long portfolioItemId, Long stockId) {
        final RecommendationTarget target = new RecommendationTarget();
        target.setUserId(userId);
        target.setPortfolioItemId(portfolioItemId);
        target.setStockId(stockId);
        target.setCompanyName("Apple");
        target.setTicker("AAPL");
        target.setLogoUrl("https://example.com/aapl.png");
        target.setDailyInvestAmount(BigDecimal.valueOf(10));
        target.setHoldingQuantity(BigDecimal.valueOf(1.25));
        target.setInvestmentStartDate(LocalDate.of(2026, 6, 1));
        target.setMemo("memo");
        return target;
    }

    private RecommendationRecord createRecord(
            Long userId,
            Long portfolioItemId,
            Long stockId,
            LocalDate recommendationDate
    ) {
        final RecommendationRecord record = new RecommendationRecord();
        record.setRecommendationId(9001L);
        record.setRecommendationDate(recommendationDate);
        record.setPortfolioItemId(portfolioItemId);
        record.setStockId(stockId);
        record.setCompanyName("Apple");
        record.setTicker("AAPL");
        record.setLogoUrl("https://example.com/aapl.png");
        record.setRecommendationStatus("MAINTAIN");
        record.setEngineScore(61);
        record.setConfidenceScore(73);
        record.setCurrentAmount(BigDecimal.valueOf(10));
        record.setRecommendedAmount(BigDecimal.valueOf(10));
        record.setFinalNote("stored");
        record.setEngineVersion("OLD_VERSION");
        record.setHoldingQuantity(BigDecimal.valueOf(1.25));
        record.setInvestmentStartDate(LocalDate.of(2026, 6, 1));
        record.setMemo("memo");
        return record;
    }

    private Object createPriceSnapshot(Double currentPrice, Double changeRate7d, Double changeRate30d)
            throws Exception {
        final Class<?> priceSnapshotClass = findNestedClass("PriceSnapshot");
        final Constructor<?> constructor = priceSnapshotClass.getDeclaredConstructors()[0];
        constructor.setAccessible(true);
        return constructor.newInstance(
                currentPrice,
                changeRate7d,
                changeRate30d,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
    }

    private Class<?> findNestedClass(String simpleName) {
        for (Class<?> nestedClass : RecommendationService.class.getDeclaredClasses()) {
            if (simpleName.equals(nestedClass.getSimpleName())) {
                return nestedClass;
            }
        }
        throw new IllegalStateException("Nested class not found: " + simpleName);
    }
}
