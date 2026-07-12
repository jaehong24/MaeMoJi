package com.maemoji.backend.portfolioinsight.dto;

import jakarta.validation.constraints.Size;

public record TestPushNotificationRequest(
        @Size(max = 120, message = "푸시 제목은 120자 이하여야 합니다.")
        String title,
        @Size(max = 500, message = "푸시 본문은 500자 이하여야 합니다.")
        String body
) {
}
