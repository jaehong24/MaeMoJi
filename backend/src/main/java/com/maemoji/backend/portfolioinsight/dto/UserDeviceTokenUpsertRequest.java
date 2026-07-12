package com.maemoji.backend.portfolioinsight.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UserDeviceTokenUpsertRequest(
        @NotBlank(message = "디바이스 플랫폼을 입력해 주세요.") String devicePlatform,
        @NotBlank(message = "FCM 토큰을 입력해 주세요.")
        @Size(max = 512, message = "FCM 토큰 길이가 너무 깁니다.")
        String fcmToken,
        @Size(max = 191, message = "디바이스 식별자가 너무 깁니다.")
        String deviceIdentifier,
        @Size(max = 50, message = "앱 버전 길이가 너무 깁니다.")
        String appVersion,
        Boolean pushEnabled
) {
}
