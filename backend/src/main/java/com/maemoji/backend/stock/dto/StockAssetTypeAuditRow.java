package com.maemoji.backend.stock.dto;

public record StockAssetTypeAuditRow(
        Long id,
        String symbol,
        String ticker,
        String nameEn,
        String assetType,
        String marketType,
        String suggestedAssetType,
        String reason
) {
}
