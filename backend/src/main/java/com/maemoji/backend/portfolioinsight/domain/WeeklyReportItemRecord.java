package com.maemoji.backend.portfolioinsight.domain;

public class WeeklyReportItemRecord {

    private Long portfolioItemId;
    private Long stockId;
    private String companyName;
    private String ticker;
    private String logoUrl;
    private String currentStatus;
    private String previousStatus;
    private Integer scoreDelta;
    private String headlineLabel;
    private String changeType;
    private String summary;

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

    public String getCurrentStatus() {
        return currentStatus;
    }

    public void setCurrentStatus(String currentStatus) {
        this.currentStatus = currentStatus;
    }

    public String getPreviousStatus() {
        return previousStatus;
    }

    public void setPreviousStatus(String previousStatus) {
        this.previousStatus = previousStatus;
    }

    public Integer getScoreDelta() {
        return scoreDelta;
    }

    public void setScoreDelta(Integer scoreDelta) {
        this.scoreDelta = scoreDelta;
    }

    public String getHeadlineLabel() {
        return headlineLabel;
    }

    public void setHeadlineLabel(String headlineLabel) {
        this.headlineLabel = headlineLabel;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }
}
