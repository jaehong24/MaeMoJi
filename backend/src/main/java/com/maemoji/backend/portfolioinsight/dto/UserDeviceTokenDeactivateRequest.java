package com.maemoji.backend.portfolioinsight.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UserDeviceTokenDeactivateRequest(
        @NotBlank(message = "비활성화할 FCM 토큰을 입력해 주세요.")
        @Size(max = 512, message = "FCM 토큰 길이가 너무 깁니다.")
        String fcmToken
) {
}
