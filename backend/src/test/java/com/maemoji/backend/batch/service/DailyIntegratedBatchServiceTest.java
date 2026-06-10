package com.maemoji.backend.batch.service;

import com.maemoji.backend.batch.dto.DailyBatchResult;
import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.stock.dto.PriceSnapshotBatchResult;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import com.maemoji.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class DailyIntegratedBatchServiceTest {

    private final StockPriceSnapshotBatchService priceService =
            mock(StockPriceSnapshotBatchService.class);
    private final RecommendationService recommendationService =
            mock(RecommendationService.class);
    private final UserMapper userMapper = mock(UserMapper.class);
    private final DailyIntegratedBatchService service =
            new DailyIntegratedBatchService(priceService, recommendationService, userMapper);

    @Test
    void 가격과추천배치를순서대로완료한다() {
        when(priceService.syncSnapshots(500, true)).thenReturn(
                new PriceSnapshotBatchResult(LocalDate.now(), 500, 500, 0, true)
        );
        when(userMapper.findActiveUserIdsWithPortfolioItems()).thenReturn(List.of(1L, 2L));
        when(recommendationService.generateLatestRecommendations(1L)).thenReturn(List.of());
        when(recommendationService.generateLatestRecommendations(2L)).thenReturn(List.of());

        final DailyBatchResult result = service.run(500);

        assertThat(result.status()).isEqualTo("SUCCESS");
        assertThat(result.recommendationCount()).isZero();
        verify(priceService).syncSnapshots(500, true);
        verify(userMapper).findActiveUserIdsWithPortfolioItems();
        verify(recommendationService).generateLatestRecommendations(1L);
        verify(recommendationService).generateLatestRecommendations(2L);
    }

    @Test
    void 일부사용자추천에실패해도부분성공으로기록한다() {
        when(priceService.syncSnapshots(500, true)).thenReturn(
                new PriceSnapshotBatchResult(LocalDate.now(), 500, 495, 5, true)
        );
        when(userMapper.findActiveUserIdsWithPortfolioItems()).thenReturn(List.of(1L, 2L));
        when(recommendationService.generateLatestRecommendations(1L)).thenReturn(List.of());
        when(recommendationService.generateLatestRecommendations(2L))
                .thenThrow(new IllegalStateException("boom"));

        final DailyBatchResult result = service.run(500);

        assertThat(result.status()).isEqualTo("PARTIAL_SUCCESS");
        verify(recommendationService).generateLatestRecommendations(1L);
        verify(recommendationService).generateLatestRecommendations(2L);
    }

    @Test
    void 가격을한건도저장하지못하면추천을생성하지않는다() {
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
        when(priceService.syncSnapshots(500, true)).thenReturn(
                new PriceSnapshotBatchResult(LocalDate.now(), 0, 0, 0, true)
        );

        final DailyBatchResult result = service.run(500);

        assertThat(result.status()).isEqualTo("FAILED");
        assertThat(result.failedStage()).isEqualTo("PRICE_SNAPSHOTS");
    }
}
