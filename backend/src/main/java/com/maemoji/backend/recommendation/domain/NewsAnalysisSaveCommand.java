package com.maemoji.backend.recommendation.domain;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public class NewsAnalysisSaveCommand {
    private Long stockId;
    private String newsId;
    private String symbol;
    private OffsetDateTime newsPublishedAt;
    private String headline;
    private String summary;
    private String sourceName;
    private String newsUrl;
    private String sentimentLabel;
    private Integer sentimentScore;
    private Integer keywordScore;
    private Integer relevanceScore;
    private String impactLevel;
    private String reason;
    private BigDecimal recencyWeight;
    private BigDecimal impactWeight;
    private BigDecimal weightedScore;
    private String contentHash;
    private String analysisBatchHash;
    private String llmModel;
    private OffsetDateTime analyzedAt;

    public Long getStockId() {
        return stockId;
    }

    public void setStockId(Long stockId) {
        this.stockId = stockId;
    }

    public String getNewsId() {
        return newsId;
    }

    public void setNewsId(String newsId) {
        this.newsId = newsId;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public OffsetDateTime getNewsPublishedAt() {
        return newsPublishedAt;
    }

    public void setNewsPublishedAt(OffsetDateTime newsPublishedAt) {
        this.newsPublishedAt = newsPublishedAt;
    }

    public String getHeadline() {
        return headline;
    }

    public void setHeadline(String headline) {
        this.headline = headline;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getSourceName() {
        return sourceName;
    }

    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }

    public String getNewsUrl() {
        return newsUrl;
    }

    public void setNewsUrl(String newsUrl) {
        this.newsUrl = newsUrl;
    }

    public String getSentimentLabel() {
        return sentimentLabel;
    }

    public void setSentimentLabel(String sentimentLabel) {
        this.sentimentLabel = sentimentLabel;
    }

    public Integer getSentimentScore() {
        return sentimentScore;
    }

    public void setSentimentScore(Integer sentimentScore) {
        this.sentimentScore = sentimentScore;
    }

    public Integer getKeywordScore() {
        return keywordScore;
    }

    public void setKeywordScore(Integer keywordScore) {
        this.keywordScore = keywordScore;
    }

    public Integer getRelevanceScore() {
        return relevanceScore;
    }

    public void setRelevanceScore(Integer relevanceScore) {
        this.relevanceScore = relevanceScore;
    }

    public String getImpactLevel() {
        return impactLevel;
    }

    public void setImpactLevel(String impactLevel) {
        this.impactLevel = impactLevel;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public BigDecimal getRecencyWeight() {
        return recencyWeight;
    }

    public void setRecencyWeight(BigDecimal recencyWeight) {
        this.recencyWeight = recencyWeight;
    }

    public BigDecimal getImpactWeight() {
        return impactWeight;
    }

    public void setImpactWeight(BigDecimal impactWeight) {
        this.impactWeight = impactWeight;
    }

    public BigDecimal getWeightedScore() {
        return weightedScore;
    }

    public void setWeightedScore(BigDecimal weightedScore) {
        this.weightedScore = weightedScore;
    }

    public String getContentHash() {
        return contentHash;
    }

    public void setContentHash(String contentHash) {
        this.contentHash = contentHash;
    }

    public String getAnalysisBatchHash() {
        return analysisBatchHash;
    }

    public void setAnalysisBatchHash(String analysisBatchHash) {
        this.analysisBatchHash = analysisBatchHash;
    }

    public String getLlmModel() {
        return llmModel;
    }

    public void setLlmModel(String llmModel) {
        this.llmModel = llmModel;
    }

    public OffsetDateTime getAnalyzedAt() {
        return analyzedAt;
    }

    public void setAnalyzedAt(OffsetDateTime analyzedAt) {
        this.analyzedAt = analyzedAt;
    }
}
