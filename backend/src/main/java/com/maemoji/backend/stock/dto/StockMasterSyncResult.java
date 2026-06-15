package com.maemoji.backend.stock.dto;

import java.time.OffsetDateTime;

public record StockMasterSyncResult(
        String status,
        String provider,
        int fetchedCount,
        int syncedCount,
        int deactivatedCount,
        OffsetDateTime startedAt,
        OffsetDateTime finishedAt
) {
}
