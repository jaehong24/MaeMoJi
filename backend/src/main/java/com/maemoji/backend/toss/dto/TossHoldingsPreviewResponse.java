package com.maemoji.backend.toss.dto;

import java.util.List;

public record TossHoldingsPreviewResponse(
        Long accountId,
        int itemCount,
        int matchedStockCount,
        int matchedPortfolioItemCount,
        List<TossHoldingPreviewItemResponse> items
) {
}
