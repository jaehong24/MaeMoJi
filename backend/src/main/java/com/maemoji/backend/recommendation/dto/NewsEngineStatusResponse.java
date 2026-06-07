package com.maemoji.backend.recommendation.dto;

public record NewsEngineStatusResponse(
        boolean finnhubConfigured,
        boolean geminiConfigured,
        String geminiModel,
        boolean geminiRequiredForDisplay,
        int maximumDailyNews,
        int minimumRelevanceScore
) {
}
