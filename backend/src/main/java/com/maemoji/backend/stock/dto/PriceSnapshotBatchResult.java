package com.maemoji.backend.stock.dto;

import java.time.LocalDate;

public record PriceSnapshotBatchResult(
        LocalDate snapshotDate,
        int requestedCount,
        int savedCount,
        int failedCount,
        boolean usedScheduler
) {
}
