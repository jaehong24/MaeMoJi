package com.maemoji.backend.batch.runner;

import com.maemoji.backend.recommendation.service.RecommendationPerformanceReportService;
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
@ConditionalOnProperty(name = "maemoji.batch.run-once", havingValue = "recommendation-performance-report")
public class RecommendationPerformanceReportRunOnceRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(RecommendationPerformanceReportRunOnceRunner.class);

    private final RecommendationPerformanceReportService reportService;
    private final ConfigurableApplicationContext applicationContext;

    public RecommendationPerformanceReportRunOnceRunner(
            RecommendationPerformanceReportService reportService,
            ConfigurableApplicationContext applicationContext
    ) {
        this.reportService = reportService;
        this.applicationContext = applicationContext;
    }

    @Override
    public void run(ApplicationArguments args) {
        final var recommendationCohorts = reportService.loadRecommendationCohorts();
        final var performanceCohorts = reportService.loadPerformanceCohorts();

        recommendationCohorts.forEach(cohort -> log.info(
                "추천 버전 표본: engine={}, formula={}, firstDate={}, lastDate={}, recommendations={}",
                cohort.engineVersion(), cohort.formulaVersion(), cohort.firstRecommendationDate(),
                cohort.lastRecommendationDate(), cohort.recommendationCount()
        ));
        performanceCohorts.forEach(cohort -> log.info(
                "추천 성과 표본: engine={}, formula={}, status={}, horizon={}d, samples={}, stockReturn={}%, strategyReturn={}%, excess={}p, maxDrawdown={}%, excessWinRate={}%",
                cohort.engineVersion(), cohort.formulaVersion(), cohort.recommendationStatus(),
                cohort.horizonDays(), cohort.sampleCount(), cohort.averageStockReturnPct(),
                cohort.averageStrategyReturnPct(), cohort.averageExcessReturnPct(),
                cohort.averageMaxDrawdownPct(), cohort.excessWinRatePct()
        ));
        log.info(
                "추천 성과 리포트를 종료합니다. recommendationCohorts={}, performanceCohorts={}",
                recommendationCohorts.size(), performanceCohorts.size()
        );
        final int exitCode = SpringApplication.exit(applicationContext, () -> 0);
        System.exit(exitCode);
    }
}
