package com.maemoji.backend.toss.dto;

public record TossAccountSelectionResponse(
        Long accountId,
        Long accountSeq,
        String message
) {
}
