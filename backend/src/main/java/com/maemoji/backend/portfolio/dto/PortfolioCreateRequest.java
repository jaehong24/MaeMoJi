package com.maemoji.backend.portfolio.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;

public record PortfolioCreateRequest(
        @NotNull(message = "stockId는 필수입니다.")
        Long stockId,

        @NotNull(message = "매일 모으기 금액은 필수입니다.")
        @DecimalMin(value = "0.01", message = "매일 모으기 금액은 0보다 커야 합니다.")
        @DecimalMax(value = "100.00", message = "매일 모으기 금액은 최대 100달러까지만 입력할 수 있습니다.")
        BigDecimal dailyInvestAmount,

        @DecimalMin(value = "0.0", inclusive = true, message = "보유 수량은 0 이상이어야 합니다.")
        BigDecimal holdingQuantity,

        LocalDate investmentStartDate,
        String memo
) {
}
