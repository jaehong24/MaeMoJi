package com.maemoji.backend.portfolioinsight.dto;

public record WeeklyReportItemResponse(
        Long portfolioItemId,
        Long stockId,
        String companyName,
        String ticker,
        String logoUrl,
        String currentStatus,
        String previousStatus,
        int scoreDelta,
        String headlineLabel,
        String changeType,
        String summary
) {
}
