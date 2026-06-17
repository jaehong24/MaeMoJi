package com.maemoji.backend.stock.dto;

import java.time.LocalDate;

public record PriceHistoryBackfillResult(
        LocalDate fromDate,
        LocalDate toDate,
        int requestedStockCount,
        int historyRowCount,
        int refreshedCurrentSnapshotCount,
        int failedStockCount
) {
}
