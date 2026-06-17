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
import org.springframework.transaction.PlatformTransactionManager;

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
}
