package com.maemoji.backend.batch.runner;

import com.maemoji.backend.batch.dto.DailyBatchResult;
import com.maemoji.backend.batch.service.DailyIntegratedBatchService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "maemoji.batch.run-once", havingValue = "daily")
public class DailyBatchRunOnceRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DailyBatchRunOnceRunner.class);

    private final DailyIntegratedBatchService dailyBatchService;
    private final ConfigurableApplicationContext applicationContext;
    private final Environment environment;

    public DailyBatchRunOnceRunner(
            DailyIntegratedBatchService dailyBatchService,
            ConfigurableApplicationContext applicationContext,
            Environment environment
    ) {
        this.dailyBatchService = dailyBatchService;
        this.applicationContext = applicationContext;
        this.environment = environment;
    }

    @Override
    public void run(ApplicationArguments args) {
        final Integer limit = environment.getProperty(
                "maemoji.batch.daily.price-limit",
                Integer.class,
                500
        );
        final DailyBatchResult result = dailyBatchService.run(limit);
        final int exitCode = result.isSuccessful() ? 0 : 1;

        log.info("일일 배치 단발 실행을 종료합니다. status={}, exitCode={}", result.status(), exitCode);
        final int springExitCode = SpringApplication.exit(applicationContext, () -> exitCode);
        System.exit(springExitCode);
    }
}
