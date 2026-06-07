package com.maemoji.backend.market.dto;

public record ExchangeRateResponse(
        String baseCurrency,
        String quoteCurrency,
        double rate
) {
}
