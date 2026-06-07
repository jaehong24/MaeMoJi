package com.maemoji.backend.recommendation.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

public class RecommendationSaveCommand {
    private Long recommendationId;
    private Long userId;
    private Long portfolioItemId;
    private LocalDate recommendationDate;
    private String recommendationStatus;
    private Integer engineScore;
    private Integer confidenceScore;
    private BigDecimal currentAmount;
    private BigDecimal recommendedAmount;
    private String finalNote;
    private String engineVersion;

    public Long getRecommendationId() {
        return recommendationId;
    }

    public void setRecommendationId(Long recommendationId) {
        this.recommendationId = recommendationId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getPortfolioItemId() {
        return portfolioItemId;
    }

    public void setPortfolioItemId(Long portfolioItemId) {
        this.portfolioItemId = portfolioItemId;
    }

    public LocalDate getRecommendationDate() {
        return recommendationDate;
    }

    public void setRecommendationDate(LocalDate recommendationDate) {
        this.recommendationDate = recommendationDate;
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
}
