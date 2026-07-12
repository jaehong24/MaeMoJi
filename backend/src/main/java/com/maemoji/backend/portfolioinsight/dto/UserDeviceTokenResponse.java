package com.maemoji.backend.portfolioinsight.dto;

import java.time.OffsetDateTime;

public record UserDeviceTokenResponse(
        Long deviceTokenId,
        String devicePlatform,
        String deviceIdentifier,
        String appVersion,
        boolean pushEnabled,
        boolean active,
        OffsetDateTime lastSeenAt,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {
}
