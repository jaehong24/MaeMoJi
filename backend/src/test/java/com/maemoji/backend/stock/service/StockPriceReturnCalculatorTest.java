package com.maemoji.backend.stock.service;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

class StockPriceReturnCalculatorTest {

    private final StockPriceReturnCalculator calculator = new StockPriceReturnCalculator();

    @Test
    void calculatesPositiveReturn() {
        assertThat(calculator.calculate(
                new BigDecimal("110.00"),
                new BigDecimal("100.00")
        )).isEqualByComparingTo("10.0000");
    }

    @Test
    void calculatesNegativeReturn() {
        assertThat(calculator.calculate(
                new BigDecimal("90.00"),
                new BigDecimal("100.00")
        )).isEqualByComparingTo("-10.0000");
    }

    @Test
    void returnsNullWithoutValidReferencePrice() {
        assertThat(calculator.calculate(new BigDecimal("100.00"), null)).isNull();
        assertThat(calculator.calculate(new BigDecimal("100.00"), BigDecimal.ZERO)).isNull();
    }
}
