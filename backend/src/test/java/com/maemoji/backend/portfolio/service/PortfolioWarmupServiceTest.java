package com.maemoji.backend.portfolio.service;

import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class PortfolioWarmupServiceTest {

    private final RecommendationService recommendationService = mock(RecommendationService.class);
    private final StockPriceSnapshotBatchService stockPriceSnapshotBatchService =
            mock(StockPriceSnapshotBatchService.class);
    private final PortfolioWarmupService portfolioWarmupService = new PortfolioWarmupService(
            recommendationService,
            stockPriceSnapshotBatchService
    );

    @Test
    void warmUpAfterPortfolioSavedEnsuresSnapshotBeforeRecommendationRefresh() {
        portfolioWarmupService.warmUpAfterPortfolioSaved(7L, 101L);

        verify(stockPriceSnapshotBatchService).ensureRecommendationSnapshot(101L);
        verify(recommendationService).warmUpLatestNewsForUserStock(7L, 101L);
        verify(recommendationService).generateLatestRecommendationsFromCachedData(7L);
    }
}
