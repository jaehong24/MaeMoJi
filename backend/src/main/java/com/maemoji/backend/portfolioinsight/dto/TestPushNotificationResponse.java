package com.maemoji.backend.portfolioinsight.dto;

public record TestPushNotificationResponse(
        boolean dispatchable,
        int targetDeviceCount,
        int successCount,
        int failureCount,
        String message
) {
}
