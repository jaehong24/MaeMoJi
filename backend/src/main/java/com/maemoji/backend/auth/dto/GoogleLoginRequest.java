package com.maemoji.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.AssertTrue;

public record GoogleLoginRequest(
        @NotBlank(message = "idToken은 필수입니다.")
        String idToken,
        @AssertTrue(message = "필수 안내 동의가 필요합니다.")
        boolean requiredConsentAccepted,
        @NotBlank(message = "동의 문서 버전은 필수입니다.")
        String consentVersion
) {
}
