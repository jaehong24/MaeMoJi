package com.maemoji.backend.batch.service;

import com.maemoji.backend.batch.security.BatchExecutionLock;
import com.maemoji.backend.portfolioinsight.service.WeeklyReportService;
import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.stock.service.StockAssetTypeMaintenanceService;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import com.maemoji.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class DailyBatchWiringTest {
    @Test
    void springCreatesServiceWithProductionConstructor() {
        try (var context = new AnnotationConfigApplicationContext()) {
            context.registerBean(StockPriceSnapshotBatchService.class, () -> mock(StockPriceSnapshotBatchService.class));
            context.registerBean(StockAssetTypeMaintenanceService.class, () -> mock(StockAssetTypeMaintenanceService.class));
            context.registerBean(RecommendationService.class, () -> mock(RecommendationService.class));
            context.registerBean(WeeklyReportService.class, () -> mock(WeeklyReportService.class));
            context.registerBean(UserMapper.class, () -> mock(UserMapper.class));
            var lock = mock(BatchExecutionLock.class);
            context.registerBean(BatchExecutionLock.class, () -> lock);
            context.register(DailyIntegratedBatchService.class);
            context.refresh();

            assertThat(context.getBean(DailyIntegratedBatchService.class))
                    .extracting("batchExecutionLock").isSameAs(lock);
        }
    }
}
