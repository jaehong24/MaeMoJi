package com.maemoji.backend.portfolioinsight.dto;

import java.time.OffsetDateTime;

public record UserAlertEventResponse(
        Long alertId,
        Long portfolioItemId,
        Long stockId,
        String alertType,
        String title,
        String body,
        boolean supplementalPriceRisk,
        OffsetDateTime sentAt,
        OffsetDateTime readAt,
        OffsetDateTime createdAt
) {
}
