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
    private String assetType;
    private String sector;
    private String industry;
    private BigDecimal dailyInvestAmount;
    private BigDecimal holdingQuantity;
    private LocalDate investmentStartDate;
    private String memo;
    private String riskProfile;
    private String investmentDnaType;

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

    public String getAssetType() {
        return assetType;
    }

    public void setAssetType(String assetType) {
        this.assetType = assetType;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
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

    public String getRiskProfile() {
        return riskProfile;
    }

    public void setRiskProfile(String riskProfile) {
        this.riskProfile = riskProfile;
    }

    public String getInvestmentDnaType() {
        return investmentDnaType;
    }

    public void setInvestmentDnaType(String investmentDnaType) {
        this.investmentDnaType = investmentDnaType;
    }
}
