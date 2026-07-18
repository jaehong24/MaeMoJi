package com.maemoji.backend.batch.service;

import com.maemoji.backend.batch.dto.DailyBatchResult;
import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.portfolioinsight.service.WeeklyReportService;
import com.maemoji.backend.stock.dto.PriceSnapshotBatchResult;
import com.maemoji.backend.stock.dto.StockAssetTypeNormalizeResult;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import com.maemoji.backend.stock.service.StockAssetTypeMaintenanceService;
import com.maemoji.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class DailyIntegratedBatchServiceTest {

    private final StockPriceSnapshotBatchService priceService =
            mock(StockPriceSnapshotBatchService.class);
    private final StockAssetTypeMaintenanceService assetTypeMaintenanceService =
            mock(StockAssetTypeMaintenanceService.class);
    private final RecommendationService recommendationService =
            mock(RecommendationService.class);
    private final WeeklyReportService weeklyReportService = mock(WeeklyReportService.class);
    private final UserMapper userMapper = mock(UserMapper.class);
    private final DailyIntegratedBatchService service =
            new DailyIntegratedBatchService(
                    priceService,
                    assetTypeMaintenanceService,
                    recommendationService,
                    weeklyReportService,
                    userMapper
            );

    @Test
    void 가격과추천배치를순서대로완료한다() {
        when(assetTypeMaintenanceService.normalizeAssetTypes()).thenReturn(
                new StockAssetTypeNormalizeResult(1, 1, 0, List.of())
        );
        when(priceService.syncSnapshots(500, true)).thenReturn(
                new PriceSnapshotBatchResult(LocalDate.now(), 500, 500, 0, true)
        );
        when(userMapper.findActiveUserIdsWithPortfolioItems()).thenReturn(List.of(1L, 2L));
        when(recommendationService.warmUpSharedNewsAnalysis()).thenReturn(
                new RecommendationService.SharedNewsAnalysisWarmupResult(Map.of(), 0, 0, 0, 0)
        );
        when(recommendationService.generateLatestRecommendations(eq(1L), anyMap())).thenReturn(List.of());
        when(recommendationService.generateLatestRecommendations(eq(2L), anyMap())).thenReturn(List.of());
        when(weeklyReportService.processImmediateAlerts(eq(1L), org.mockito.ArgumentMatchers.any(LocalDate.class)))
                .thenReturn(new WeeklyReportService.ImmediateAlertProcessingResult(0, 0, 0, 0));
        when(weeklyReportService.processImmediateAlerts(eq(2L), org.mockito.ArgumentMatchers.any(LocalDate.class)))
                .thenReturn(new WeeklyReportService.ImmediateAlertProcessingResult(0, 0, 0, 0));

        final DailyBatchResult result = service.run(500);

        assertThat(result.status()).isEqualTo("SUCCESS");
        assertThat(result.recommendationCount()).isZero();
        verify(assetTypeMaintenanceService).normalizeAssetTypes();
        verify(priceService).syncSnapshots(500, true);
        verify(userMapper).findActiveUserIdsWithPortfolioItems();
        verify(recommendationService).warmUpSharedNewsAnalysis();
        verify(recommendationService).generateLatestRecommendations(eq(1L), anyMap());
        verify(recommendationService).generateLatestRecommendations(eq(2L), anyMap());
        verify(weeklyReportService).processImmediateAlerts(eq(1L), org.mockito.ArgumentMatchers.any(LocalDate.class));
        verify(weeklyReportService).processImmediateAlerts(eq(2L), org.mockito.ArgumentMatchers.any(LocalDate.class));
    }

    @Test
    void 일부사용자추천에실패해도부분성공으로기록한다() {
        when(assetTypeMaintenanceService.normalizeAssetTypes()).thenReturn(
                new StockAssetTypeNormalizeResult(0, 0, 0, List.of())
        );
        when(priceService.syncSnapshots(500, true)).thenReturn(
                new PriceSnapshotBatchResult(LocalDate.now(), 500, 495, 5, true)
        );
        when(userMapper.findActiveUserIdsWithPortfolioItems()).thenReturn(List.of(1L, 2L));
        when(recommendationService.warmUpSharedNewsAnalysis()).thenReturn(
                new RecommendationService.SharedNewsAnalysisWarmupResult(Map.of(), 0, 0, 0, 0)
        );
        when(recommendationService.generateLatestRecommendations(eq(1L), anyMap())).thenReturn(List.of());
        when(weeklyReportService.processImmediateAlerts(eq(1L), org.mockito.ArgumentMatchers.any(LocalDate.class)))
                .thenReturn(new WeeklyReportService.ImmediateAlertProcessingResult(0, 0, 0, 0));
        when(recommendationService.generateLatestRecommendations(eq(2L), anyMap()))
                .thenThrow(new IllegalStateException("boom"));

        final DailyBatchResult result = service.run(500);

        assertThat(result.status()).isEqualTo("PARTIAL_SUCCESS");
        verify(recommendationService).warmUpSharedNewsAnalysis();
        verify(recommendationService).generateLatestRecommendations(eq(1L), anyMap());
        verify(recommendationService).generateLatestRecommendations(eq(2L), anyMap());
    }

    @Test
    void 가격을한건도저장하지못하면추천을생성하지않는다() {
        when(assetTypeMaintenanceService.normalizeAssetTypes()).thenReturn(
                new StockAssetTypeNormalizeResult(0, 0, 0, List.of())
        );
        when(priceService.syncSnapshots(500, true)).thenReturn(
                new PriceSnapshotBatchResult(LocalDate.now(), 500, 0, 500, true)
        );

        final DailyBatchResult result = service.run(500);

        assertThat(result.status()).isEqualTo("FAILED");
        assertThat(result.failedStage()).isEqualTo("PRICE_SNAPSHOTS");
        assertThat(result.errorMessage()).contains("한 건도");
    }

    @Test
    void 조회대상종목이없어도실패로기록한다() {
        when(assetTypeMaintenanceService.normalizeAssetTypes()).thenReturn(
                new StockAssetTypeNormalizeResult(0, 0, 0, List.of())
        );
        when(priceService.syncSnapshots(500, true)).thenReturn(
                new PriceSnapshotBatchResult(LocalDate.now(), 0, 0, 0, true)
        );

        final DailyBatchResult result = service.run(500);

        assertThat(result.status()).isEqualTo("FAILED");
        assertThat(result.failedStage()).isEqualTo("PRICE_SNAPSHOTS");
    }
}
