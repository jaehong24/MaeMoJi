package com.maemoji.backend.recommendation.dto;

public record RecommendationCalculationResponse(
        String formulaVersion,
        int rawScore,
        int finalScore,
        int riskAdjustment,
        Integer priceScore,
        Integer newsScore,
        int priceWeight,
        int newsWeight,
        Double thirtyDayReturn,
        Integer newsSentimentScore,
        boolean increaseEligible
) {
}
