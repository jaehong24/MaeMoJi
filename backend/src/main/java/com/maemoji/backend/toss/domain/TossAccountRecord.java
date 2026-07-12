package com.maemoji.backend.toss.domain;

import java.time.OffsetDateTime;

public class TossAccountRecord {

    private Long id;
    private Long connectionId;
    private Long accountSeq;
    private String accountType;
    private String accountNoMasked;
    private String displayName;
    private String status;
    private Boolean isSelected;
    private Boolean isActive;
    private OffsetDateTime lastSyncedAt;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getConnectionId() {
        return connectionId;
    }

    public void setConnectionId(Long connectionId) {
        this.connectionId = connectionId;
    }

    public Long getAccountSeq() {
        return accountSeq;
    }

    public void setAccountSeq(Long accountSeq) {
        this.accountSeq = accountSeq;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public String getAccountNoMasked() {
        return accountNoMasked;
    }

    public void setAccountNoMasked(String accountNoMasked) {
        this.accountNoMasked = accountNoMasked;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getIsSelected() {
        return isSelected;
    }

    public void setIsSelected(Boolean selected) {
        isSelected = selected;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean active) {
        isActive = active;
    }

    public OffsetDateTime getLastSyncedAt() {
        return lastSyncedAt;
    }

    public void setLastSyncedAt(OffsetDateTime lastSyncedAt) {
        this.lastSyncedAt = lastSyncedAt;
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
