package com.maemoji.backend.portfolioinsight.domain;

import java.time.LocalDate;
import java.time.OffsetDateTime;

public class WeeklyReportRecord {

    private Long id;
    private LocalDate reportWeek;
    private OffsetDateTime generatedAt;
    private String headline;
    private String summary;
    private Integer changedItemCount;
    private Integer alertItemCount;
    private Integer positiveItemCount;
    private Integer negativeItemCount;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDate getReportWeek() {
        return reportWeek;
    }

    public void setReportWeek(LocalDate reportWeek) {
        this.reportWeek = reportWeek;
    }

    public OffsetDateTime getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(OffsetDateTime generatedAt) {
        this.generatedAt = generatedAt;
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

    public Integer getChangedItemCount() {
        return changedItemCount;
    }

    public void setChangedItemCount(Integer changedItemCount) {
        this.changedItemCount = changedItemCount;
    }

    public Integer getAlertItemCount() {
        return alertItemCount;
    }

    public void setAlertItemCount(Integer alertItemCount) {
        this.alertItemCount = alertItemCount;
    }

    public Integer getPositiveItemCount() {
        return positiveItemCount;
    }

    public void setPositiveItemCount(Integer positiveItemCount) {
        this.positiveItemCount = positiveItemCount;
    }

    public Integer getNegativeItemCount() {
        return negativeItemCount;
    }

    public void setNegativeItemCount(Integer negativeItemCount) {
        this.negativeItemCount = negativeItemCount;
    }
}
