package com.maemoji.backend.recommendation.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

public record HomeRecommendationResponse(
        OffsetDateTime calculatedAt,
        LocalDate priceDataDate,
        OffsetDateTime newsAnalyzedAt,
        List<RecommendationResponse> items
) {
}
