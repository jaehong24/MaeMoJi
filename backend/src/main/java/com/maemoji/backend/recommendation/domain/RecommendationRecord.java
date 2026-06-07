package com.maemoji.backend.recommendation.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

public class RecommendationRecord {
    private Long recommendationId;
    private LocalDate recommendationDate;
    private Long portfolioItemId;
    private Long stockId;
    private String companyName;
    private String ticker;
    private String logoUrl;
    private String recommendationStatus;
    private Integer engineScore;
    private Integer confidenceScore;
    private BigDecimal currentAmount;
    private BigDecimal recommendedAmount;
    private String finalNote;
    private String engineVersion;
    private String formulaVersion;
    private Integer rawScore;
    private Integer riskAdjustment;
    private Integer priceScore;
    private Integer newsScore;
    private Integer priceWeight;
    private Integer newsWeight;
    private BigDecimal priceReturn30d;
    private Integer newsSentimentScore;
    private Boolean increaseEligible;
    private BigDecimal holdingQuantity;
    private LocalDate investmentStartDate;
    private String memo;

    public Long getRecommendationId() {
        return recommendationId;
    }

    public void setRecommendationId(Long recommendationId) {
        this.recommendationId = recommendationId;
    }

    public LocalDate getRecommendationDate() {
        return recommendationDate;
    }

    public void setRecommendationDate(LocalDate recommendationDate) {
        this.recommendationDate = recommendationDate;
    }

    public Long getPortfolioItemId() {
        return portfolioItemId;
    }

    public void setPortfolioItemId(Long portfolioItemId) {
        this.portfolioItemId = portfolioItemId;
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

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public String getRecommendationStatus() {
        return recommendationStatus;
    }

    public void setRecommendationStatus(String recommendationStatus) {
        this.recommendationStatus = recommendationStatus;
    }

    public Integer getEngineScore() {
        return engineScore;
    }

    public void setEngineScore(Integer engineScore) {
        this.engineScore = engineScore;
    }

    public Integer getConfidenceScore() {
        return confidenceScore;
    }

    public void setConfidenceScore(Integer confidenceScore) {
        this.confidenceScore = confidenceScore;
    }

    public BigDecimal getCurrentAmount() {
        return currentAmount;
    }

    public void setCurrentAmount(BigDecimal currentAmount) {
        this.currentAmount = currentAmount;
    }

    public BigDecimal getRecommendedAmount() {
        return recommendedAmount;
    }

    public void setRecommendedAmount(BigDecimal recommendedAmount) {
        this.recommendedAmount = recommendedAmount;
    }

    public String getFinalNote() {
        return finalNote;
    }

    public void setFinalNote(String finalNote) {
        this.finalNote = finalNote;
    }

    public String getEngineVersion() {
        return engineVersion;
    }

    public void setEngineVersion(String engineVersion) {
        this.engineVersion = engineVersion;
    }

    public String getFormulaVersion() {
        return formulaVersion;
    }

    public void setFormulaVersion(String formulaVersion) {
        this.formulaVersion = formulaVersion;
    }

    public Integer getRawScore() {
        return rawScore;
    }

    public void setRawScore(Integer rawScore) {
        this.rawScore = rawScore;
    }

    public Integer getRiskAdjustment() {
        return riskAdjustment;
    }

    public void setRiskAdjustment(Integer riskAdjustment) {
        this.riskAdjustment = riskAdjustment;
    }

    public Integer getPriceScore() {
        return priceScore;
    }

    public void setPriceScore(Integer priceScore) {
        this.priceScore = priceScore;
    }

    public Integer getNewsScore() {
        return newsScore;
    }

    public void setNewsScore(Integer newsScore) {
        this.newsScore = newsScore;
    }

    public Integer getPriceWeight() {
        return priceWeight;
    }

    public void setPriceWeight(Integer priceWeight) {
        this.priceWeight = priceWeight;
    }

    public Integer getNewsWeight() {
        return newsWeight;
    }

    public void setNewsWeight(Integer newsWeight) {
        this.newsWeight = newsWeight;
    }

    public BigDecimal getPriceReturn30d() {
        return priceReturn30d;
    }

    public void setPriceReturn30d(BigDecimal priceReturn30d) {
        this.priceReturn30d = priceReturn30d;
    }

    public Integer getNewsSentimentScore() {
        return newsSentimentScore;
    }

    public void setNewsSentimentScore(Integer newsSentimentScore) {
        this.newsSentimentScore = newsSentimentScore;
    }

    public Boolean getIncreaseEligible() {
        return increaseEligible;
    }

    public void setIncreaseEligible(Boolean increaseEligible) {
        this.increaseEligible = increaseEligible;
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
