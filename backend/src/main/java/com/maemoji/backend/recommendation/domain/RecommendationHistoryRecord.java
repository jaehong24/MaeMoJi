package com.maemoji.backend.recommendation.domain;

import java.time.LocalDate;
import java.time.OffsetDateTime;

public record RecommendationHistoryRecord(
        Long recommendationId,
        LocalDate recommendationDate,
        OffsetDateTime generatedAt,
        String recommendationStatus,
        Integer engineScore,
        String finalNote,
        String coreFactorCode,
        String coreFactorSummary
) {
}
