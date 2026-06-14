package com.maemoji.backend.recommendation.domain;

public class RecommendationFactorDetailRecord {
    private Long recommendationId;
    private String factorCode;
    private Integer factorScore;
    private Integer factorWeight;
    private String factorSummary;
    private String factorRawJson;

    public Long getRecommendationId() {
        return recommendationId;
    }

    public void setRecommendationId(Long recommendationId) {
        this.recommendationId = recommendationId;
    }

    public String getFactorCode() {
        return factorCode;
    }

    public void setFactorCode(String factorCode) {
        this.factorCode = factorCode;
    }

    public Integer getFactorScore() {
        return factorScore;
    }

    public void setFactorScore(Integer factorScore) {
        this.factorScore = factorScore;
    }

    public Integer getFactorWeight() {
        return factorWeight;
    }

    public void setFactorWeight(Integer factorWeight) {
        this.factorWeight = factorWeight;
    }

    public String getFactorSummary() {
        return factorSummary;
    }

    public void setFactorSummary(String factorSummary) {
        this.factorSummary = factorSummary;
    }

    public String getFactorRawJson() {
        return factorRawJson;
    }

    public void setFactorRawJson(String factorRawJson) {
        this.factorRawJson = factorRawJson;
    }
}
