package com.maemoji.backend.stock.domain;

public record StockMasterItem(
        String symbol,
        String nameEn,
        String exchange,
        String assetType,
        String currency,
        String country,
        String sector,
        String industry,
        String logoUrl
) {
}
