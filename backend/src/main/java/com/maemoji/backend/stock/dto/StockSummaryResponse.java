package com.maemoji.backend.stock.dto;

public record StockSummaryResponse(
        Long id,
        String ticker,
        String exchangeCode,
        String nameKo,
        String nameEn,
        String logoUrl
) {
}
