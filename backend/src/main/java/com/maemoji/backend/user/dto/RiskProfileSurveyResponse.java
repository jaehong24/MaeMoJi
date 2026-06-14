package com.maemoji.backend.user.dto;

import java.util.Map;

public record RiskProfileSurveyResponse(
        int score,
        String riskProfile,
        String investmentDnaType,
        String title,
        String summary,
        String preference,
        Map<String, Integer> suggestedAllocation
) {
}
