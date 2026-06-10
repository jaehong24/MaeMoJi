package com.maemoji.backend.auth.dto;

public record AuthUserResponse(
        Long userId,
        String email,
        String nickname,
        String profileImageUrl
) {
}
