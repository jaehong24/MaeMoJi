package com.maemoji.backend.recommendation.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

public record RecommendationResponse(
        Long recommendationId,
        Long portfolioItemId,
        Long stockId,
        String companyName,
        String ticker,
        String logoUrl,
        String assetType,
        String analysisStageMessage,
        String recommendationType,
        int finalScore,
        int confidence,
        BigDecimal currentDailyAmount,
        BigDecimal recommendedDailyAmount,
        String currentHolding,
        String investmentStartDate,
        String memo,
        String aiFinalComment,
        String engineVersion,
        LocalDate recommendationDate,
        OffsetDateTime recommendationGeneratedAt,
        OffsetDateTime newsAnalyzedAt,
        String relatedNewsStatusMessage,
        RecommendationScoresResponse scores,
        RecommendationCalculationResponse calculation,
        List<RecommendationEvidenceResponse> evidence,
        List<RelatedNewsResponse> relatedNews
) {
}
