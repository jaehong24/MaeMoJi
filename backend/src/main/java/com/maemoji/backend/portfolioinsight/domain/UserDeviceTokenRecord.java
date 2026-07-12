package com.maemoji.backend.portfolioinsight.domain;

import java.time.OffsetDateTime;

public class UserDeviceTokenRecord {

    private Long id;
    private Long userId;
    private String devicePlatform;
    private String deviceIdentifier;
    private String fcmToken;
    private String appVersion;
    private Boolean pushEnabled;
    private Boolean isActive;
    private OffsetDateTime lastSeenAt;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
    private OffsetDateTime deactivatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getDevicePlatform() { return devicePlatform; }
    public void setDevicePlatform(String devicePlatform) { this.devicePlatform = devicePlatform; }
    public String getDeviceIdentifier() { return deviceIdentifier; }
    public void setDeviceIdentifier(String deviceIdentifier) { this.deviceIdentifier = deviceIdentifier; }
    public String getFcmToken() { return fcmToken; }
    public void setFcmToken(String fcmToken) { this.fcmToken = fcmToken; }
    public String getAppVersion() { return appVersion; }
    public void setAppVersion(String appVersion) { this.appVersion = appVersion; }
    public Boolean getPushEnabled() { return pushEnabled; }
    public void setPushEnabled(Boolean pushEnabled) { this.pushEnabled = pushEnabled; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean active) { isActive = active; }
    public OffsetDateTime getLastSeenAt() { return lastSeenAt; }
    public void setLastSeenAt(OffsetDateTime lastSeenAt) { this.lastSeenAt = lastSeenAt; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }
    public OffsetDateTime getDeactivatedAt() { return deactivatedAt; }
    public void setDeactivatedAt(OffsetDateTime deactivatedAt) { this.deactivatedAt = deactivatedAt; }
}
