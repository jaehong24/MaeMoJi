package com.maemoji.backend.stock.runner;

import com.maemoji.backend.stock.dto.StockMasterSyncResult;
import com.maemoji.backend.stock.service.StockSyncService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Order(Ordered.LOWEST_PRECEDENCE)
@ConditionalOnProperty(name = "maemoji.batch.run-once", havingValue = "stock-master")
public class StockMasterSyncRunOnceRunner implements ApplicationRunner {

    private static final Logger log =
            LoggerFactory.getLogger(StockMasterSyncRunOnceRunner.class);

    private final StockSyncService stockSyncService;
    private final ConfigurableApplicationContext applicationContext;

    public StockMasterSyncRunOnceRunner(
            StockSyncService stockSyncService,
            ConfigurableApplicationContext applicationContext
    ) {
        this.stockSyncService = stockSyncService;
        this.applicationContext = applicationContext;
    }

    @Override
    public void run(ApplicationArguments args) {
        int exitCode = 0;
        try {
            final StockMasterSyncResult result = stockSyncService.syncAll();
            log.info(
                    "종목 마스터 단발 실행을 종료합니다. provider={}, synced={}, deactivated={}",
                    result.provider(),
                    result.syncedCount(),
                    result.deactivatedCount()
            );
        } catch (Exception exception) {
            exitCode = 1;
            log.error("종목 마스터 단발 실행에 실패했습니다.", exception);
        }

        final int finalExitCode = exitCode;
        final int springExitCode = SpringApplication.exit(
                applicationContext,
                () -> finalExitCode
        );
        System.exit(springExitCode);
    }
}
