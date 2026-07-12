package com.maemoji.backend.portfolioinsight.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

public record WeeklyReportResponse(
        Long reportId,
        LocalDate reportWeek,
        OffsetDateTime generatedAt,
        String headline,
        String summary,
        int changedItemCount,
        int alertItemCount,
        int positiveItemCount,
        int negativeItemCount,
        List<WeeklyReportItemResponse> items
) {
}
