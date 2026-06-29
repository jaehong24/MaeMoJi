package com.maemoji.backend.batch.runner;

import com.maemoji.backend.stock.dto.PriceHistoryBackfillResult;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
@Order(Ordered.LOWEST_PRECEDENCE)
@ConditionalOnProperty(name = "maemoji.batch.run-once", havingValue = "price-null-30d")
public class NullThirtyDayBackfillRunOnceRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(NullThirtyDayBackfillRunOnceRunner.class);

    private final StockPriceSnapshotBatchService stockPriceSnapshotBatchService;
    private final ConfigurableApplicationContext applicationContext;
    private final Environment environment;

    public NullThirtyDayBackfillRunOnceRunner(
            StockPriceSnapshotBatchService stockPriceSnapshotBatchService,
            ConfigurableApplicationContext applicationContext,
            Environment environment
    ) {
        this.stockPriceSnapshotBatchService = stockPriceSnapshotBatchService;
        this.applicationContext = applicationContext;
        this.environment = environment;
    }

    @Override
    public void run(ApplicationArguments args) {
        final Integer limit = environment.getProperty(
                "maemoji.batch.price-snapshots.null-30d-limit",
                Integer.class,
                300
        );
        final Integer lookbackDays = environment.getProperty(
                "maemoji.batch.price-snapshots.null-30d-lookback-days",
                Integer.class,
                120
        );

        final PriceHistoryBackfillResult result =
                stockPriceSnapshotBatchService.backfillNullThirtyDaySnapshots(limit, lookbackDays);

        final boolean failed = result.failedStockCount() > 0;
        final int exitCode = failed ? 1 : 0;

        log.info(
                "30일 수익률 null 복구 단발 실행을 종료합니다. requested={}, historyRows={}, refreshedCurrent={}, failedStocks={}, exitCode={}",
                result.requestedStockCount(),
                result.historyRowCount(),
                result.refreshedCurrentSnapshotCount(),
                result.failedStockCount(),
                exitCode
        );

        final int springExitCode = SpringApplication.exit(applicationContext, () -> exitCode);
        System.exit(springExitCode);
    }
}
