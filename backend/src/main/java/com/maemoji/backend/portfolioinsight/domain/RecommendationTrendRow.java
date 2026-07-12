package com.maemoji.backend.portfolioinsight.domain;

public class RecommendationTrendRow {

    private Long portfolioItemId;
    private Long stockId;
    private String companyName;
    private String ticker;
    private String logoUrl;
    private String recommendationStatus;
    private Integer engineScore;
    private Integer newsScore;
    private Integer priceMomentumScore;
    private Integer priceStabilityScore;
    private Integer fundamentalQualityScore;
    private Integer rowNumber;

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

    public Integer getNewsScore() {
        return newsScore;
    }

    public void setNewsScore(Integer newsScore) {
        this.newsScore = newsScore;
    }

    public Integer getPriceMomentumScore() {
        return priceMomentumScore;
    }

    public void setPriceMomentumScore(Integer priceMomentumScore) {
        this.priceMomentumScore = priceMomentumScore;
    }

    public Integer getPriceStabilityScore() {
        return priceStabilityScore;
    }

    public void setPriceStabilityScore(Integer priceStabilityScore) {
        this.priceStabilityScore = priceStabilityScore;
    }

    public Integer getFundamentalQualityScore() {
        return fundamentalQualityScore;
    }

    public void setFundamentalQualityScore(Integer fundamentalQualityScore) {
        this.fundamentalQualityScore = fundamentalQualityScore;
    }

    public Integer getRowNumber() {
        return rowNumber;
    }

    public void setRowNumber(Integer rowNumber) {
        this.rowNumber = rowNumber;
    }
}
