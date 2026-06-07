package com.maemoji.backend.recommendation.dto;

public record RecommendationScoresResponse(
        int businessHealth,
        int valuation,
        int priceOverheating,
        int newsSentiment,
        int institutionalConfidence
) {
}
