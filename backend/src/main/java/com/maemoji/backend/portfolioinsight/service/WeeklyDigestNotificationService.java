package com.maemoji.backend.portfolioinsight.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.maemoji.backend.portfolioinsight.domain.UserDeviceTokenRecord;
import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import com.maemoji.backend.portfolioinsight.dto.WeeklyReportResponse;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class WeeklyDigestNotificationService {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final PortfolioInsightMapper portfolioInsightMapper;
    private final PushNotificationPolicyService pushNotificationPolicyService;
    private final FirebaseMessagingGateway firebaseMessagingGateway;

    public WeeklyDigestNotificationService(
            PortfolioInsightMapper portfolioInsightMapper,
            PushNotificationPolicyService pushNotificationPolicyService,
            FirebaseMessagingGateway firebaseMessagingGateway
    ) {
        this.portfolioInsightMapper = portfolioInsightMapper;
        this.pushNotificationPolicyService = pushNotificationPolicyService;
        this.firebaseMessagingGateway = firebaseMessagingGateway;
    }

    public WeeklyDigestDispatchPlan planWeeklyDigest(Long userId, WeeklyReportResponse report) {
        final UserNotificationPreferenceRecord preference =
                portfolioInsightMapper.findNotificationPreferenceByUserId(userId);

        if (!pushNotificationPolicyService.isWeeklyDigestEligible(preference)) {
            return new WeeklyDigestDispatchPlan(userId, "", "", Map.of(), List.of());
        }

        final List<UserDeviceTokenRecord> activeDevices = portfolioInsightMapper.findDeviceTokensByUserId(userId).stream()
                .filter(record -> Boolean.TRUE.equals(record.getIsActive()))
                .filter(record -> Boolean.TRUE.equals(record.getPushEnabled()))
                .toList();

        final String title = report.alertItemCount() > 0
                ? "이번 주 다시 볼 종목이 " + report.alertItemCount() + "개 있어요"
                : "이번 주 매모지 리포트가 도착했어요";
        final String body = report.summary();

        return new WeeklyDigestDispatchPlan(
                userId,
                title,
                body,
                Map.of(
                        "type", "WEEKLY_REPORT",
                        "reportId", String.valueOf(report.reportId()),
                        "reportWeek", report.reportWeek() == null ? "" : report.reportWeek().toString()
                ),
                activeDevices
        );
    }

    public WeeklyDigestDispatchResult dispatchWeeklyDigest(Long userId, WeeklyReportResponse report) {
        final WeeklyDigestDispatchPlan plan = planWeeklyDigest(userId, report);
        final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));

        final int inserted = portfolioInsightMapper.insertWeeklyNotificationJobIfAbsent(
                userId,
                report.reportId(),
                report.reportWeek(),
                now
        );

        if (inserted == 0) {
            return new WeeklyDigestDispatchResult(false, 0, 0, 0, "이번 주 주간 알림은 이미 처리되었습니다.");
        }

        if (!hasMeaningfulChange(report)) {
            portfolioInsightMapper.updateWeeklyNotificationJobResult(
                    userId,
                    report.reportWeek(),
                    "NO_CHANGE",
                    0,
                    0,
                    0,
                    now,
                    now,
                    "사용자에게 알릴 만한 변화가 없어 발송하지 않았습니다."
            );
            return new WeeklyDigestDispatchResult(false, 0, 0, 0, "중요한 변화가 없어 알림을 보내지 않았습니다.");
        }

        if (!plan.dispatchable()) {
            portfolioInsightMapper.updateWeeklyNotificationJobResult(
                    userId,
                    report.reportWeek(),
                    "SKIPPED",
                    0,
                    0,
                    0,
                    now,
                    now,
                    "주간 푸시 대상 디바이스가 없거나 알림이 꺼져 있습니다."
            );
            return new WeeklyDigestDispatchResult(false, 0, 0, 0, "대상 디바이스가 없습니다.");
        }

        final List<Message> messages = new ArrayList<>();
        final List<UserDeviceTokenRecord> dispatchDevices = new ArrayList<>();
        final List<String> dedupeKeys = new ArrayList<>();
        final String payloadJson = serializePayload(plan.data());
        for (UserDeviceTokenRecord device : plan.targetDevices()) {
            final String dedupeKey = "weekly:" + report.reportId() + ":device:" + device.getId();
            final int deliveryInserted = portfolioInsightMapper.insertPushNotificationDelivery(
                    null,
                    userId,
                    device.getId(),
                    "WEEKLY_DIGEST",
                    "WEEKLY_REPORT",
                    dedupeKey,
                    plan.title(),
                    plan.body(),
                    payloadJson
            );
            if (deliveryInserted == 0) {
                continue;
            }
            messages.add(Message.builder()
                    .setToken(device.getFcmToken())
                    .setNotification(Notification.builder()
                            .setTitle(plan.title())
                            .setBody(plan.body())
                            .build())
                    .putAllData(plan.data())
                    .setAndroidConfig(AndroidConfig.builder()
                            .setPriority(AndroidConfig.Priority.NORMAL)
                            .setNotification(AndroidNotification.builder()
                                    .setChannelId("maemoji_weekly_digest")
                                    .build())
                            .build())
                    .build());
            dispatchDevices.add(device);
            dedupeKeys.add(dedupeKey);
        }

        if (messages.isEmpty()) {
            return new WeeklyDigestDispatchResult(false, 0, 0, 0, "주간 푸시는 이미 발송했거나 재시도 대기 중입니다.");
        }

        try {
            final List<FirebaseMessagingGateway.SendResult> results = firebaseMessagingGateway.sendEach(messages);
            int successCount = 0;
            int failureCount = 0;
            for (int index = 0; index < results.size(); index++) {
                final FirebaseMessagingGateway.SendResult result = results.get(index);
                if (result.successful()) {
                    portfolioInsightMapper.updatePushNotificationDeliverySuccess(dedupeKeys.get(index), result.messageId(), now);
                    successCount++;
                } else {
                    portfolioInsightMapper.updatePushNotificationDeliveryFailure(
                            dedupeKeys.get(index), safeErrorCode(result.errorCode()), safeErrorMessage(result.errorMessage()), now
                    );
                    failureCount++;
                    if (isPermanentTokenError(result.errorCode())) {
                        final UserDeviceTokenRecord device = dispatchDevices.get(index);
                        portfolioInsightMapper.deactivateDeviceToken(userId, device.getFcmToken(), now);
                    }
                }
            }

            portfolioInsightMapper.updateWeeklyNotificationJobResult(
                    userId,
                    report.reportWeek(),
                    failureCount == 0 ? "SUCCESS" : "PARTIAL_SUCCESS",
                    dispatchDevices.size(),
                    successCount,
                    failureCount,
                    now,
                    now,
                    null
            );

            return new WeeklyDigestDispatchResult(true, dispatchDevices.size(), successCount, failureCount, null);
        } catch (Exception exception) {
            for (String dedupeKey : dedupeKeys) {
                portfolioInsightMapper.updatePushNotificationDeliveryFailure(
                        dedupeKey, "FIREBASE_SEND_ERROR", safeExceptionMessage(exception), now
                );
            }
            portfolioInsightMapper.updateWeeklyNotificationJobResult(
                    userId,
                    report.reportWeek(),
                    "FAILED",
                    dispatchDevices.size(),
                    0,
                    dispatchDevices.size(),
                    now,
                    now,
                    exception.getMessage()
            );
            return new WeeklyDigestDispatchResult(
                    false,
                    dispatchDevices.size(),
                    0,
                    dispatchDevices.size(),
                    exception.getMessage()
            );
        }
    }

    public record WeeklyDigestDispatchPlan(
            Long userId,
            String title,
            String body,
            Map<String, String> data,
            List<UserDeviceTokenRecord> targetDevices
    ) {
        public boolean dispatchable() {
            return !targetDevices.isEmpty();
        }
    }

    public record WeeklyDigestDispatchResult(
            boolean dispatched,
            int targetDeviceCount,
            int successCount,
            int failureCount,
            String message
    ) {
    }

    private boolean isPermanentTokenError(String errorCode) {
        return "UNREGISTERED".equals(errorCode)
                || "SENDER_ID_MISMATCH".equals(errorCode)
                || "registration-token-not-registered".equals(errorCode)
                || "mismatched-credential".equals(errorCode);
    }

    private String serializePayload(Map<String, String> data) {
        try {
            return OBJECT_MAPPER.writeValueAsString(data);
        } catch (JsonProcessingException exception) {
            return "{}";
        }
    }

    private String safeErrorCode(String errorCode) {
        return errorCode == null || errorCode.isBlank() ? "UNKNOWN" : errorCode;
    }

    private String safeErrorMessage(String errorMessage) {
        return errorMessage == null || errorMessage.isBlank()
                ? "Firebase에서 실패 사유를 반환하지 않았습니다."
                : errorMessage;
    }

    private String safeExceptionMessage(Exception exception) {
        final String message = exception.getMessage();
        return message == null || message.isBlank() ? "Firebase 발송 처리 중 예외가 발생했습니다." : message;
    }

    private boolean hasMeaningfulChange(WeeklyReportResponse report) {
        return report != null && (report.changedItemCount() > 0 || report.alertItemCount() > 0);
    }
}
