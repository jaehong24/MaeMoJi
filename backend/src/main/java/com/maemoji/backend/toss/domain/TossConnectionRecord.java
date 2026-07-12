package com.maemoji.backend.toss.domain;

import java.time.OffsetDateTime;

public class TossConnectionRecord {

    private Long id;
    private Long userId;
    private String connectionName;
    private String clientId;
    private String clientSecretEncrypted;
    private String clientSecretMasked;
    private String status;
    private OffsetDateTime lastTokenIssuedAt;
    private OffsetDateTime lastSyncAt;
    private String lastSyncStatus;
    private String lastSyncErrorCode;
    private String lastSyncErrorMessage;
    private Boolean isPrimary;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getConnectionName() {
        return connectionName;
    }

    public void setConnectionName(String connectionName) {
        this.connectionName = connectionName;
    }

    public String getClientId() {
        return clientId;
    }

    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    public String getClientSecretEncrypted() {
        return clientSecretEncrypted;
    }

    public void setClientSecretEncrypted(String clientSecretEncrypted) {
        this.clientSecretEncrypted = clientSecretEncrypted;
    }

    public String getClientSecretMasked() {
        return clientSecretMasked;
    }

    public void setClientSecretMasked(String clientSecretMasked) {
        this.clientSecretMasked = clientSecretMasked;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public OffsetDateTime getLastTokenIssuedAt() {
        return lastTokenIssuedAt;
    }

    public void setLastTokenIssuedAt(OffsetDateTime lastTokenIssuedAt) {
        this.lastTokenIssuedAt = lastTokenIssuedAt;
    }

    public OffsetDateTime getLastSyncAt() {
        return lastSyncAt;
    }

    public void setLastSyncAt(OffsetDateTime lastSyncAt) {
        this.lastSyncAt = lastSyncAt;
    }

    public String getLastSyncStatus() {
        return lastSyncStatus;
    }

    public void setLastSyncStatus(String lastSyncStatus) {
        this.lastSyncStatus = lastSyncStatus;
    }

    public String getLastSyncErrorCode() {
        return lastSyncErrorCode;
    }

    public void setLastSyncErrorCode(String lastSyncErrorCode) {
        this.lastSyncErrorCode = lastSyncErrorCode;
    }

    public String getLastSyncErrorMessage() {
        return lastSyncErrorMessage;
    }

    public void setLastSyncErrorMessage(String lastSyncErrorMessage) {
        this.lastSyncErrorMessage = lastSyncErrorMessage;
    }

    public Boolean getIsPrimary() {
        return isPrimary;
    }

    public void setIsPrimary(Boolean primary) {
        isPrimary = primary;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(OffsetDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
