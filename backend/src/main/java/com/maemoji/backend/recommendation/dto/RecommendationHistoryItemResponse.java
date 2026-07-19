package com.maemoji.backend.recommendation.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;

public record RecommendationHistoryItemResponse(
        Long recommendationId,
        LocalDate recommendationDate,
        OffsetDateTime generatedAt,
        String status,
        String previousStatus,
        int score,
        Integer previousScore,
        int scoreDelta,
        String changeType,
        String headline,
        String summary
) {
}
