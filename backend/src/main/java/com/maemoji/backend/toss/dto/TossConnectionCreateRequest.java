package com.maemoji.backend.toss.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record TossConnectionCreateRequest(
        @NotBlank(message = "연결 이름을 입력해주세요.")
        @Size(max = 100, message = "연결 이름은 100자 이하로 입력해주세요.")
        String connectionName,
        @NotBlank(message = "client_id를 입력해주세요.")
        @Size(max = 255, message = "client_id 길이가 너무 깁니다.")
        String clientId,
        @NotBlank(message = "client_secret을 입력해주세요.")
        String clientSecret
) {
}
