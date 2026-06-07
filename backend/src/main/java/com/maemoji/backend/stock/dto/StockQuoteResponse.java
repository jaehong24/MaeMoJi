package com.maemoji.backend.stock.dto;

public record StockQuoteResponse(
        Long stockId,
        String symbol,
        double currentPrice,
        double change,
        double percentChange,
        double previousClose,
        Long quoteTimestamp
) {
}
