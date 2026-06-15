package com.maemoji.backend.stock.dto;

public record StockSummaryResponse(
        Long id,
        String symbol,
        String ticker,
        String exchange,
        String exchangeCode,
        String nameKo,
        String nameEn,
        String logoUrl,
        String assetType
) {
}
