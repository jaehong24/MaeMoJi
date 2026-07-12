package com.maemoji.backend.toss.dto;

public record TossAccountResponse(
        Long accountId,
        Long accountSeq,
        String displayName,
        String accountType,
        String status,
        boolean isSelected
) {
}
