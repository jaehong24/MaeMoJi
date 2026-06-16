package com.maemoji.backend.recommendation.dto;

public record RecommendationEvidenceResponse(
        String evidenceType,
        String title,
        String body,
        Integer scoreImpact,
        Integer displayOrder,
        String rawDataJson
) {
}
