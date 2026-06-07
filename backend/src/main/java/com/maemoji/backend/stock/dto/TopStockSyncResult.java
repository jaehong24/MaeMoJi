package com.maemoji.backend.stock.dto;

public record TopStockSyncResult(
        int candidateCount,
        int selectedCount,
        int syncedCount,
        boolean scheduledRun
) {
}
