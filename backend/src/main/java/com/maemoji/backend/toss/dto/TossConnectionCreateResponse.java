package com.maemoji.backend.toss.dto;

public record TossConnectionCreateResponse(
        Long connectionId,
        String status,
        String message,
        int accountCount
) {
}
