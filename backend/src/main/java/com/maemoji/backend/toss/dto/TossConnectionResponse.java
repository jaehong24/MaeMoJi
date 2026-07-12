package com.maemoji.backend.toss.dto;

import java.time.OffsetDateTime;

public record TossConnectionResponse(
        Long connectionId,
        String connectionName,
        String status,
        String clientIdMasked,
        boolean isPrimary,
        OffsetDateTime lastSyncAt,
        String lastSyncStatus
) {
}
