package com.maemoji.backend.user.domain;

import java.time.OffsetDateTime;

public class UserSessionRecord {

    private Long id;
    private String email;
    private String nickname;
    private String profileImageUrl;
    private String googleSubject;
    private String authToken;
    private OffsetDateTime authTokenExpiresAt;
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

    public String getGoogleSubject() {
        return googleSubject;
    }

    public void setGoogleSubject(String googleSubject) {
        this.googleSubject = googleSubject;
    }

    public String getAuthToken() {
        return authToken;
    }

    public void setAuthToken(String authToken) {
        this.authToken = authToken;
    }

    public OffsetDateTime getAuthTokenExpiresAt() {
        return authTokenExpiresAt;
    }

    public void setAuthTokenExpiresAt(OffsetDateTime authTokenExpiresAt) {
        this.authTokenExpiresAt = authTokenExpiresAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
