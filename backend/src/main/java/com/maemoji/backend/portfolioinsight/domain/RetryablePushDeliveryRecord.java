package com.maemoji.backend.portfolioinsight.domain;

public class RetryablePushDeliveryRecord {
    private Long id;
    private Long userId;
    private Long deviceTokenId;
    private String fcmToken;
    private String dedupeKey;
    private String title;
    private String body;
    private String payloadJson;
    private String alertType;
    private String notificationKind;

    public Long getId() { return id; }
    public void setId(Long value) { id = value; }
    public Long getUserId() { return userId; }
    public void setUserId(Long value) { userId = value; }
    public Long getDeviceTokenId() { return deviceTokenId; }
    public void setDeviceTokenId(Long value) { deviceTokenId = value; }
    public String getFcmToken() { return fcmToken; }
    public void setFcmToken(String value) { fcmToken = value; }
    public String getDedupeKey() { return dedupeKey; }
    public void setDedupeKey(String value) { dedupeKey = value; }
    public String getTitle() { return title; }
    public void setTitle(String value) { title = value; }
    public String getBody() { return body; }
    public void setBody(String value) { body = value; }
    public String getPayloadJson() { return payloadJson; }
    public void setPayloadJson(String value) { payloadJson = value; }
    public String getAlertType() { return alertType; }
    public void setAlertType(String value) { alertType = value; }
    public String getNotificationKind() { return notificationKind; }
    public void setNotificationKind(String value) { notificationKind = value; }
}
