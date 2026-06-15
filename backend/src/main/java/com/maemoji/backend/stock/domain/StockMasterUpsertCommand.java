package com.maemoji.backend.stock.domain;

import java.time.OffsetDateTime;

public record StockMasterUpsertCommand(
        String symbol,
        String nameEn,
        String nameKo,
        String exchange,
        String assetType,
        String currency,
        String country,
        String sector,
        String industry,
        String tickerNormalized,
        String nameKoNormalized,
        String nameEnNormalized,
        String searchText,
        String logoUrl,
        OffsetDateTime syncedAt
) {
}
