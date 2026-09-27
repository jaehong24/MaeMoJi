package com.maemoji.backend.batch.runner;

import com.maemoji.backend.recommendation.service.RecommendationPerformanceEvaluationService;
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

import java.time.LocalDate;
import java.time.ZoneId;

@Component
@Order(Ordered.LOWEST_PRECEDENCE)
@ConditionalOnProperty(name = "maemoji.batch.run-once", havingValue = "recommendation-performance")
public class RecommendationPerformanceRunOnceRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(RecommendationPerformanceRunOnceRunner.class);
    private static final ZoneId BATCH_ZONE = ZoneId.of("Asia/Seoul");

    private final RecommendationPerformanceEvaluationService evaluationService;
    private final ConfigurableApplicationContext applicationContext;

    public RecommendationPerformanceRunOnceRunner(
            RecommendationPerformanceEvaluationService evaluationService,
            ConfigurableApplicationContext applicationContext
    ) {
        this.evaluationService = evaluationService;
        this.applicationContext = applicationContext;
    }

    @Override
    public void run(ApplicationArguments args) {
        final LocalDate evaluationDate = LocalDate.now(BATCH_ZONE);
        final int inserted = evaluationService.evaluateDueRecommendations(evaluationDate);
        log.info("추천 성과 평가 단발 실행을 종료합니다. evaluationDate={}, inserted={}", evaluationDate, inserted);
        final int exitCode = SpringApplication.exit(applicationContext, () -> 0);
        System.exit(exitCode);
    }
}
