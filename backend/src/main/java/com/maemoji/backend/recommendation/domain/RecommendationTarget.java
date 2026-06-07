package com.maemoji.backend.recommendation.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

public class RecommendationTarget {
    private Long portfolioItemId;
    private Long userId;
    private Long stockId;
    private String companyName;
    private String ticker;
    private String finnhubSymbol;
    private String logoUrl;
    private BigDecimal dailyInvestAmount;
    private BigDecimal holdingQuantity;
    private LocalDate investmentStartDate;
    private String memo;

    public Long getPortfolioItemId() {
        return portfolioItemId;
    }

    public void setPortfolioItemId(Long portfolioItemId) {
        this.portfolioItemId = portfolioItemId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getStockId() {
        return stockId;
    }

    public void setStockId(Long stockId) {
        this.stockId = stockId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getTicker() {
        return ticker;
    }

    public void setTicker(String ticker) {
        this.ticker = ticker;
    }

    public String getFinnhubSymbol() {
        return finnhubSymbol;
    }

    public void setFinnhubSymbol(String finnhubSymbol) {
        this.finnhubSymbol = finnhubSymbol;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public BigDecimal getDailyInvestAmount() {
        return dailyInvestAmount;
    }

    public void setDailyInvestAmount(BigDecimal dailyInvestAmount) {
        this.dailyInvestAmount = dailyInvestAmount;
    }

    public BigDecimal getHoldingQuantity() {
        return holdingQuantity;
    }

    public void setHoldingQuantity(BigDecimal holdingQuantity) {
        this.holdingQuantity = holdingQuantity;
    }

    public LocalDate getInvestmentStartDate() {
        return investmentStartDate;
    }

    public void setInvestmentStartDate(LocalDate investmentStartDate) {
        this.investmentStartDate = investmentStartDate;
    }

    public String getMemo() {
        return memo;
    }

    public void setMemo(String memo) {
        this.memo = memo;
    }
}
