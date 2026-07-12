package com.maemoji.backend.portfolioinsight.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;

public record WeeklyReportListItemResponse(
        Long reportId,
        LocalDate reportWeek,
        OffsetDateTime generatedAt,
        String headline,
        int changedItemCount,
        int alertItemCount
) {
}
