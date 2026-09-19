package com.maemoji.backend.stock.dto;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public record PriceHistoryBackfillResult(
        LocalDate fromDate,
        LocalDate toDate,
        int requestedStockCount,
        int historyRowCount,
        int refreshedCurrentSnapshotCount,
        int failedStockCount,
        List<String> failedTickers,
        int deferredStockCount,
        Map<String, Integer> deferredByReason
) {
}
