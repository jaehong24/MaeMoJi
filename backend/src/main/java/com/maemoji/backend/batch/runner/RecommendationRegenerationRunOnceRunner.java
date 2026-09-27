package com.maemoji.backend.batch.runner;

import com.maemoji.backend.recommendation.dto.RecommendationResponse;
import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.user.mapper.UserMapper;
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

import java.util.List;

@Component
@Order(Ordered.LOWEST_PRECEDENCE)
@ConditionalOnProperty(name = "maemoji.batch.run-once", havingValue = "recommendation-regeneration")
public class RecommendationRegenerationRunOnceRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(RecommendationRegenerationRunOnceRunner.class);

    private final UserMapper userMapper;
    private final RecommendationService recommendationService;
    private final ConfigurableApplicationContext applicationContext;

    public RecommendationRegenerationRunOnceRunner(
            UserMapper userMapper,
            RecommendationService recommendationService,
            ConfigurableApplicationContext applicationContext
    ) {
        this.userMapper = userMapper;
        this.recommendationService = recommendationService;
        this.applicationContext = applicationContext;
    }

    @Override
    public void run(ApplicationArguments args) {
        final RegenerationResult result = regenerate();
        final int exitCode = result.failedUserCount() == 0 ? 0 : 1;
        log.info(
                "캐시 기반 전체 추천 재생성을 종료합니다. users={}, recommendations={}, failedUsers={}, exitCode={}",
                result.userCount(), result.recommendationCount(), result.failedUserCount(), exitCode
        );
        final int springExitCode = SpringApplication.exit(applicationContext, () -> exitCode);
        System.exit(springExitCode);
    }

    RegenerationResult regenerate() {
        final List<Long> userIds = userMapper.findActiveUserIdsWithPortfolioItems();
        int recommendationCount = 0;
        int failedUserCount = 0;

        log.info("캐시 기반 전체 추천 재생성을 시작합니다. users={}", userIds.size());
        for (Long userId : userIds) {
            try {
                final List<RecommendationResponse> recommendations =
                        recommendationService.generateLatestRecommendationsFromCachedData(userId);
                recommendationCount += recommendations.size();
            } catch (Exception exception) {
                failedUserCount++;
                log.warn("캐시 기반 추천 재생성에 실패했습니다. userId={}", userId, exception);
            }
        }

        return new RegenerationResult(userIds.size(), recommendationCount, failedUserCount);
    }

    record RegenerationResult(int userCount, int recommendationCount, int failedUserCount) {
    }
}
