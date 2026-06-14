package com.maemoji.backend.user.domain;

import java.time.OffsetDateTime;

public class UserSessionRecord {

    private Long id;
    private String email;
    private String nickname;
    private String profileImageUrl;
    private Boolean nicknameConfirmed;
    private String googleSubject;
    private String riskProfile;
    private String investmentDnaType;
    private Integer riskProfileScore;
    private Integer riskProfileConfidence;
    private String riskProfileSource;
    private String authToken;
    private String authTokenHash;
    private OffsetDateTime authTokenExpiresAt;
    private OffsetDateTime riskProfileUpdatedAt;
    private String status;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }

    public Boolean getNicknameConfirmed() {
        return nicknameConfirmed;
    }

    public void setNicknameConfirmed(Boolean nicknameConfirmed) {
        this.nicknameConfirmed = nicknameConfirmed;
    }

    public String getGoogleSubject() {
        return googleSubject;
    }

    public void setGoogleSubject(String googleSubject) {
        this.googleSubject = googleSubject;
    }

    public String getRiskProfile() {
        return riskProfile;
    }

    public void setRiskProfile(String riskProfile) {
        this.riskProfile = riskProfile;
    }

    public String getInvestmentDnaType() {
        return investmentDnaType;
    }

    public void setInvestmentDnaType(String investmentDnaType) {
        this.investmentDnaType = investmentDnaType;
    }

    public Integer getRiskProfileScore() {
        return riskProfileScore;
    }

    public void setRiskProfileScore(Integer riskProfileScore) {
        this.riskProfileScore = riskProfileScore;
    }

    public Integer getRiskProfileConfidence() {
        return riskProfileConfidence;
    }

    public void setRiskProfileConfidence(Integer riskProfileConfidence) {
        this.riskProfileConfidence = riskProfileConfidence;
    }

    public String getRiskProfileSource() {
        return riskProfileSource;
    }

    public void setRiskProfileSource(String riskProfileSource) {
        this.riskProfileSource = riskProfileSource;
    }

    public String getAuthToken() {
        return authToken;
    }

    public void setAuthToken(String authToken) {
        this.authToken = authToken;
    }

    public String getAuthTokenHash() {
        return authTokenHash;
    }

    public void setAuthTokenHash(String authTokenHash) {
        this.authTokenHash = authTokenHash;
    }

    public OffsetDateTime getAuthTokenExpiresAt() {
        return authTokenExpiresAt;
    }

    public void setAuthTokenExpiresAt(OffsetDateTime authTokenExpiresAt) {
        this.authTokenExpiresAt = authTokenExpiresAt;
    }

    public OffsetDateTime getRiskProfileUpdatedAt() {
        return riskProfileUpdatedAt;
    }

    public void setRiskProfileUpdatedAt(OffsetDateTime riskProfileUpdatedAt) {
        this.riskProfileUpdatedAt = riskProfileUpdatedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
