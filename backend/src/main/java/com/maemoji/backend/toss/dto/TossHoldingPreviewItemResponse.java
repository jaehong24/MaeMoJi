package com.maemoji.backend.toss.dto;

import java.math.BigDecimal;

public record TossHoldingPreviewItemResponse(
        String symbol,
        String stockName,
        BigDecimal quantity,
        BigDecimal averagePurchasePrice,
        BigDecimal currentPrice,
        BigDecimal profitRate,
        BigDecimal weightPercent,
        Long matchedStockId,
        Long matchedPortfolioItemId,
        boolean willCreatePortfolioItem
) {
}
