package com.maemoji.backend.user.dto;

public record NicknameAvailabilityResponse(
        String nickname,
        boolean available,
        String message
) {
}
