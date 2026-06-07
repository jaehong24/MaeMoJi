package com.maemoji.backend.recommendation.dto;

import java.math.BigDecimal;
import java.util.List;

public record RecommendationResponse(
        Long recommendationId,
        Long portfolioItemId,
        Long stockId,
        String companyName,
        String ticker,
        String logoUrl,
        String recommendationType,
        int finalScore,
        int confidence,
        BigDecimal currentDailyAmount,
        BigDecimal recommendedDailyAmount,
        String currentHolding,
        String investmentStartDate,
        String memo,
        String aiFinalComment,
        String engineVersion,
        RecommendationScoresResponse scores,
        RecommendationCalculationResponse calculation,
        List<RecommendationEvidenceResponse> evidence,
        List<RelatedNewsResponse> relatedNews
) {
}
