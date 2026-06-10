package com.maemoji.backend.auth.dto;

import java.time.OffsetDateTime;

public record AuthLoginResponse(
        String accessToken,
        OffsetDateTime expiresAt,
        AuthUserResponse user
) {
}
