package com.maemoji.backend.batch.dto;

import com.maemoji.backend.stock.dto.PriceSnapshotBatchResult;

import java.time.OffsetDateTime;

public record DailyBatchResult(
        String status,
        OffsetDateTime startedAt,
        OffsetDateTime finishedAt,
        PriceSnapshotBatchResult priceSnapshots,
        int recommendationCount,
        String failedStage,
        String errorMessage
) {
    public boolean isSuccessful() {
        return "SUCCESS".equals(status) || "PARTIAL_SUCCESS".equals(status);
    }
}
