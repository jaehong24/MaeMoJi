package com.maemoji.backend.recommendation.dto;

import java.math.BigDecimal;

public record RelatedNewsResponse(
        String headline,
        String summary,
        String sourceName,
        String newsUrl,
        String sentimentLabel,
        Integer sentimentScore,
        Integer relevanceScore,
        String impactLevel,
        String reason,
        BigDecimal weightedScore
) {
}
