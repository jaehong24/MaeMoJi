package com.maemoji.backend.stock.service;

import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Component
public class StockPriceReturnCalculator {

    public BigDecimal calculate(BigDecimal currentPrice, BigDecimal referencePrice) {
        if (currentPrice == null
                || referencePrice == null
                || currentPrice.signum() <= 0
                || referencePrice.signum() <= 0) {
            return null;
        }

        return currentPrice
                .subtract(referencePrice)
                .divide(referencePrice, 8, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .setScale(4, RoundingMode.HALF_UP);
    }
}
