package com.maemoji.backend.portfolioinsight.domain;

import java.time.LocalTime;
import java.time.OffsetDateTime;

public class UserNotificationPreferenceRecord {

    private Long id;
    private Long userId;
    private Boolean instantAlertEnabled;
    private Boolean weeklyDigestEnabled;
    private Boolean priceRiskAlertEnabled;
    private Boolean newsWeakenedAlertEnabled;
    private Boolean statusChangedAlertEnabled;
    private Boolean quietHoursEnabled;
    private LocalTime quietHoursStart;
    private LocalTime quietHoursEnd;
    private String timezone;
    private String weeklyDigestDay;
    private LocalTime weeklyDigestTime;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Boolean getInstantAlertEnabled() { return instantAlertEnabled; }
    public void setInstantAlertEnabled(Boolean instantAlertEnabled) { this.instantAlertEnabled = instantAlertEnabled; }
    public Boolean getWeeklyDigestEnabled() { return weeklyDigestEnabled; }
    public void setWeeklyDigestEnabled(Boolean weeklyDigestEnabled) { this.weeklyDigestEnabled = weeklyDigestEnabled; }
    public Boolean getPriceRiskAlertEnabled() { return priceRiskAlertEnabled; }
    public void setPriceRiskAlertEnabled(Boolean priceRiskAlertEnabled) { this.priceRiskAlertEnabled = priceRiskAlertEnabled; }
    public Boolean getNewsWeakenedAlertEnabled() { return newsWeakenedAlertEnabled; }
    public void setNewsWeakenedAlertEnabled(Boolean newsWeakenedAlertEnabled) { this.newsWeakenedAlertEnabled = newsWeakenedAlertEnabled; }
    public Boolean getStatusChangedAlertEnabled() { return statusChangedAlertEnabled; }
    public void setStatusChangedAlertEnabled(Boolean statusChangedAlertEnabled) { this.statusChangedAlertEnabled = statusChangedAlertEnabled; }
    public Boolean getQuietHoursEnabled() { return quietHoursEnabled; }
    public void setQuietHoursEnabled(Boolean quietHoursEnabled) { this.quietHoursEnabled = quietHoursEnabled; }
    public LocalTime getQuietHoursStart() { return quietHoursStart; }
    public void setQuietHoursStart(LocalTime quietHoursStart) { this.quietHoursStart = quietHoursStart; }
    public LocalTime getQuietHoursEnd() { return quietHoursEnd; }
    public void setQuietHoursEnd(LocalTime quietHoursEnd) { this.quietHoursEnd = quietHoursEnd; }
    public String getTimezone() { return timezone; }
    public void setTimezone(String timezone) { this.timezone = timezone; }
    public String getWeeklyDigestDay() { return weeklyDigestDay; }
    public void setWeeklyDigestDay(String weeklyDigestDay) { this.weeklyDigestDay = weeklyDigestDay; }
    public LocalTime getWeeklyDigestTime() { return weeklyDigestTime; }
    public void setWeeklyDigestTime(LocalTime weeklyDigestTime) { this.weeklyDigestTime = weeklyDigestTime; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }
}
