package com.maemoji.backend.auth.dto;

public record AuthUserResponse(
        Long userId,
        String email,
        String nickname,
        String profileImageUrl,
        boolean nicknameConfirmed,
        String riskProfile,
        String investmentDnaType,
        Integer riskProfileScore,
        Integer riskProfileConfidence,
        String riskProfileSource
) {
}
