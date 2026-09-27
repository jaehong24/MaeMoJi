package com.maemoji.backend.batch.runner;

import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.springframework.context.ConfigurableApplicationContext;

import java.util.List;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RecommendationRegenerationRunOnceRunnerTest {

    @Test
    void regeneratesRecommendationsFromCachedDataForEveryActiveUser() {
        final UserMapper userMapper = mock(UserMapper.class);
        final RecommendationService recommendationService = mock(RecommendationService.class);
        final ConfigurableApplicationContext context = mock(ConfigurableApplicationContext.class);
        when(userMapper.findActiveUserIdsWithPortfolioItems()).thenReturn(List.of(11L, 22L));
        when(recommendationService.generateLatestRecommendationsFromCachedData(11L)).thenReturn(List.of());
        when(recommendationService.generateLatestRecommendationsFromCachedData(22L)).thenReturn(List.of());

        final RecommendationRegenerationRunOnceRunner runner =
                new RecommendationRegenerationRunOnceRunner(userMapper, recommendationService, context);

        final RecommendationRegenerationRunOnceRunner.RegenerationResult result = runner.regenerate();

        org.assertj.core.api.Assertions.assertThat(result.userCount()).isEqualTo(2);
        org.assertj.core.api.Assertions.assertThat(result.recommendationCount()).isZero();
        org.assertj.core.api.Assertions.assertThat(result.failedUserCount()).isZero();
        verify(recommendationService).generateLatestRecommendationsFromCachedData(11L);
        verify(recommendationService).generateLatestRecommendationsFromCachedData(22L);
    }
}
