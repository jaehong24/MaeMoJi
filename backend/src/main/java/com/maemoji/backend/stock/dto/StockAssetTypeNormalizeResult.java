package com.maemoji.backend.stock.dto;

import java.util.List;

public record StockAssetTypeNormalizeResult(
        int suspiciousCountBefore,
        int updatedCount,
        int suspiciousCountAfter,
        List<StockAssetTypeAuditRow> suspiciousPreview
) {
}
