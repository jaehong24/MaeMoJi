package com.maemoji.backend.user.service;

import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.user.dto.RiskProfileSurveyResponse;
import com.maemoji.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class RiskProfileServiceTest {

    @Test
    void resurveyRegeneratesRecommendationsWithCachedData() {
        final UserMapper userMapper = mock(UserMapper.class);
        final InvestmentDnaScorer investmentDnaScorer = new InvestmentDnaScorer();
        final RecommendationService recommendationService = mock(RecommendationService.class);
        final RiskProfileService riskProfileService = new RiskProfileService(
                userMapper,
                investmentDnaScorer,
                recommendationService
        );

        final RiskProfileSurveyResponse response = riskProfileService.saveOnboardingSurvey(
                7L,
                List.of(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5),
                "MANUAL_UPDATE"
        );

        assertThat(response.investmentDnaType()).isEqualTo("WEALTH_MASTER");
        verify(userMapper).updateRiskProfile(
                eq(7L),
                eq(response.riskProfile()),
                eq(response.investmentDnaType()),
                eq(response.score()),
                eq(100),
                eq("MANUAL_UPDATE"),
                any()
        );
        verify(recommendationService).generateLatestRecommendationsFromCachedData(7L);
    }
}
