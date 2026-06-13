package com.maemoji.backend.recommendation.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

public record HomeRecommendationResponse(
        OffsetDateTime calculatedAt,
        OffsetDateTime recommendationGeneratedAt,
        LocalDate priceDataDate,
        OffsetDateTime newsAnalyzedAt,
        List<RecommendationResponse> items
) {
}
