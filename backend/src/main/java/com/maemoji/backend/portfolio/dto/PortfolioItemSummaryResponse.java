package com.maemoji.backend.portfolio.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record PortfolioItemSummaryResponse(
        Long id,
        Long stockId,
        String companyName,
        String ticker,
        String exchangeCode,
        BigDecimal dailyInvestAmount,
        BigDecimal holdingQuantity,
        LocalDate investmentStartDate,
        String memo,
        String logoUrl
) {
}
