package com.maemoji.backend.user.service;

import com.maemoji.backend.user.dto.RiskProfileSurveyResponse;
import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.user.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;

@Service
public class RiskProfileService {

    private static final Set<String> ALLOWED_SOURCES = Set.of(
            "ONBOARDING_SURVEY",
            "MANUAL_UPDATE"
    );

    private final UserMapper userMapper;
    private final InvestmentDnaScorer investmentDnaScorer;
    private final RecommendationService recommendationService;

    public RiskProfileService(
            UserMapper userMapper,
            InvestmentDnaScorer investmentDnaScorer,
            RecommendationService recommendationService
    ) {
        this.userMapper = userMapper;
        this.investmentDnaScorer = investmentDnaScorer;
        this.recommendationService = recommendationService;
    }

    @Transactional
    public RiskProfileSurveyResponse saveOnboardingSurvey(
            Long userId,
            List<Integer> answers,
            String source
    ) {
        final InvestmentDnaScorer.ScoringResult result =
                investmentDnaScorer.calculate(answers);
        final String normalizedSource = normalizeSource(source);
        userMapper.updateRiskProfile(
                userId,
                result.riskProfile(),
                result.investmentDnaType(),
                result.score(),
                100,
                normalizedSource,
                OffsetDateTime.now()
        );
        // 설문 직후 저장된 가격/뉴스 기준으로 추천을 다시 계산해
        // 홈과 상세가 사용자 성향 변경을 바로 반영하도록 맞춥니다.
        recommendationService.generateLatestRecommendationsFromCachedData(userId);

        return new RiskProfileSurveyResponse(
                result.score(),
                result.riskProfile(),
                result.investmentDnaType(),
                result.title(),
                result.summary(),
                result.preference(),
                result.suggestedAllocation()
        );
    }

    private String normalizeSource(String source) {
        if (source == null || source.isBlank()) {
            return "ONBOARDING_SURVEY";
        }
        final String normalized = source.trim().toUpperCase();
        return ALLOWED_SOURCES.contains(normalized)
                ? normalized
                : "ONBOARDING_SURVEY";
    }
}
