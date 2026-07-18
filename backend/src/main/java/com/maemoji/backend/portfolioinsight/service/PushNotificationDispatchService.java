package com.maemoji.backend.portfolioinsight.service;

import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.WebpushConfig;
import com.google.firebase.messaging.WebpushNotification;
import com.maemoji.backend.portfolioinsight.dto.TestPushNotificationRequest;
import com.maemoji.backend.portfolioinsight.dto.TestPushNotificationResponse;
import com.maemoji.backend.portfolioinsight.domain.UserAlertEventRecord;
import com.maemoji.backend.portfolioinsight.domain.UserDeviceTokenRecord;
import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Locale;
import java.util.Set;

@Service
public class PushNotificationDispatchService {

    private static final Set<String> PERMANENT_TOKEN_ERROR_CODES = Set.of(
            "UNREGISTERED",
            "SENDER_ID_MISMATCH",
            "registration-token-not-registered",
            "mismatched-credential"
    );

    private final PortfolioInsightMapper portfolioInsightMapper;
    private final PushNotificationPolicyService pushNotificationPolicyService;
    private final FirebaseMessagingGateway firebaseMessagingGateway;

    public PushNotificationDispatchService(
            PortfolioInsightMapper portfolioInsightMapper,
            PushNotificationPolicyService pushNotificationPolicyService,
            FirebaseMessagingGateway firebaseMessagingGateway
    ) {
        this.portfolioInsightMapper = portfolioInsightMapper;
        this.pushNotificationPolicyService = pushNotificationPolicyService;
        this.firebaseMessagingGateway = firebaseMessagingGateway;
    }

    public PushDispatchPlan planImmediateDispatch(Long userId, UserAlertEventRecord alertEvent) {
        final UserNotificationPreferenceRecord preference =
                portfolioInsightMapper.findNotificationPreferenceByUserId(userId);
        final OffsetDateTime now = OffsetDateTime.now(
                ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE)
        );

        if (!pushNotificationPolicyService.isImmediatePushEligible(alertEvent, preference)) {
            return PushDispatchPlan.inAppOnly(
                    userId,
                    pushNotificationPolicyService.resolveNotificationKind(alertEvent),
                    "현재 정책상 푸시 발송 대상이 아닙니다."
            );
        }
        if (pushNotificationPolicyService.isSuppressedByQuietHours(preference, now)) {
            return PushDispatchPlan.inAppOnly(
                    userId,
                    pushNotificationPolicyService.resolveNotificationKind(alertEvent),
                    "사용자 조용한 시간 설정으로 즉시 푸시를 보류합니다."
            );
        }
        final OffsetDateTime lastSuccessfulSentAt =
                portfolioInsightMapper.findLatestSuccessfulPushSentAt(
                        userId,
                        alertEvent.getPortfolioItemId(),
                        safeText(alertEvent.getAlertType())
                );
        if (pushNotificationPolicyService.isWithinCooldown(alertEvent, lastSuccessfulSentAt, now)) {
            return PushDispatchPlan.inAppOnly(
                    userId,
                    pushNotificationPolicyService.resolveNotificationKind(alertEvent),
                    "같은 성격의 알림이 최근에 발송되어 이번 푸시는 생략합니다."
            );
        }

        final List<UserDeviceTokenRecord> activeDevices = portfolioInsightMapper.findDeviceTokensByUserId(userId).stream()
                .filter(record -> Boolean.TRUE.equals(record.getIsActive()))
                .filter(record -> Boolean.TRUE.equals(record.getPushEnabled()))
                .toList();

        return new PushDispatchPlan(
                userId,
                pushNotificationPolicyService.resolveNotificationKind(alertEvent),
                alertEvent.getTitle(),
                alertEvent.getBody(),
                Map.of(
                        "type", "ALERT_EVENT",
                        "alertId", String.valueOf(alertEvent.getId()),
                        "portfolioItemId", String.valueOf(alertEvent.getPortfolioItemId()),
                        "stockId", String.valueOf(alertEvent.getStockId()),
                        "alertType", safeText(alertEvent.getAlertType()),
                        "focusSection", resolveFocusSection(alertEvent)
                ),
                activeDevices
        );
    }

    public PushDispatchResult dispatchImmediate(Long userId, UserAlertEventRecord alertEvent) {
        final PushDispatchPlan plan = planImmediateDispatch(userId, alertEvent);
        if (!plan.dispatchable()) {
            return PushDispatchResult.notDispatched(plan.targetDevices().size(), plan.body());
        }

        final List<Message> messages = new ArrayList<>();
        final List<String> dedupeKeys = new ArrayList<>();
        final List<UserDeviceTokenRecord> targetDevices = new ArrayList<>();
        final String payloadJson = String.valueOf(plan.data());

        for (UserDeviceTokenRecord device : plan.targetDevices()) {
            final String dedupeKey = "alert:" + alertEvent.getId() + ":device:" + device.getId();
            final int inserted = portfolioInsightMapper.insertPushNotificationDelivery(
                    alertEvent.getId(),
                    userId,
                    device.getId(),
                    plan.notificationKind(),
                    safeText(alertEvent.getAlertType()),
                    dedupeKey,
                    plan.title(),
                    plan.body(),
                    payloadJson
            );
            if (inserted == 0) {
                continue;
            }

            dedupeKeys.add(dedupeKey);
            targetDevices.add(device);
            messages.add(buildMessage(device.getFcmToken(), plan.title(), plan.body(), plan.data()));
        }

        if (messages.isEmpty()) {
            return PushDispatchResult.notDispatched(plan.targetDevices().size(), "이미 같은 푸시를 발송했습니다.");
        }

        final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));
        try {
            final List<FirebaseMessagingGateway.SendResult> results = firebaseMessagingGateway.sendEach(messages);
            int successCount = 0;
            int failureCount = 0;

            for (int index = 0; index < results.size(); index++) {
                final FirebaseMessagingGateway.SendResult result = results.get(index);
                final String dedupeKey = dedupeKeys.get(index);
                if (result.successful()) {
                    portfolioInsightMapper.updatePushNotificationDeliverySuccess(dedupeKey, result.messageId(), now);
                    successCount++;
                } else {
                    portfolioInsightMapper.updatePushNotificationDeliveryFailure(
                            dedupeKey,
                            safeErrorCode(result.errorCode()),
                            result.errorMessage(),
                            now
                    );
                    deactivateInvalidToken(userId, targetDevices.get(index), result, now);
                    failureCount++;
                }
            }

            return new PushDispatchResult(true, plan.targetDevices().size(), successCount, failureCount, null);
        } catch (Exception exception) {
            for (String dedupeKey : dedupeKeys) {
                portfolioInsightMapper.updatePushNotificationDeliveryFailure(
                        dedupeKey,
                        "FIREBASE_SEND_ERROR",
                        exception.getMessage(),
                        now
                );
            }
            return new PushDispatchResult(false, plan.targetDevices().size(), 0, dedupeKeys.size(), exception.getMessage());
        }
    }

    public TestPushNotificationResponse sendTestPush(Long userId, TestPushNotificationRequest request) {
        final List<UserDeviceTokenRecord> activeDevices = portfolioInsightMapper.findDeviceTokensByUserId(userId).stream()
                .filter(record -> Boolean.TRUE.equals(record.getIsActive()))
                .filter(record -> Boolean.TRUE.equals(record.getPushEnabled()))
                .toList();

        if (activeDevices.isEmpty()) {
            return new TestPushNotificationResponse(false, 0, 0, 0, "활성화된 디바이스 토큰이 없습니다.");
        }

        final String alertType = normalizeAlertType(request == null ? null : request.alertType());
        final String title = normalize(
                request == null ? null : request.title(),
                defaultTestTitle(alertType)
        );
        final String body = normalize(
                request == null ? null : request.body(),
                defaultTestBody(alertType)
        );
        final Long portfolioItemId = portfolioInsightMapper.findLatestActivePortfolioItemIdByUserId(userId);
        final Map<String, String> data = new LinkedHashMap<>();
        data.put("type", "ALERT_EVENT");
        data.put("alertType", alertType);
        data.put("focusSection", resolveFocusSection(alertType));
        if (portfolioItemId != null && portfolioItemId > 0) {
            data.put("portfolioItemId", String.valueOf(portfolioItemId));
        }

        final List<Message> messages = activeDevices.stream()
                .map(device -> buildMessage(device.getFcmToken(), title, body, data))
                .toList();

        try {
            final List<FirebaseMessagingGateway.SendResult> results = firebaseMessagingGateway.sendEach(messages);
            int successCount = 0;
            int failureCount = 0;
            final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));
            for (int index = 0; index < results.size(); index++) {
                final FirebaseMessagingGateway.SendResult result = results.get(index);
                if (result.successful()) {
                    successCount++;
                } else {
                    deactivateInvalidToken(userId, activeDevices.get(index), result, now);
                    failureCount++;
                }
            }
            return new TestPushNotificationResponse(
                    successCount > 0,
                    activeDevices.size(),
                    successCount,
                    failureCount,
                    successCount > 0
                            ? "테스트 푸시를 발송했어요."
                            : "푸시 발송은 시도했지만 성공한 디바이스가 없습니다."
            );
        } catch (Exception exception) {
            return new TestPushNotificationResponse(
                    false,
                    activeDevices.size(),
                    0,
                    activeDevices.size(),
                    "테스트 푸시 발송 실패: " + exception.getMessage()
            );
        }
    }

    private Message buildMessage(
            String token,
            String title,
            String body,
            Map<String, String> data
    ) {
        final WebpushNotification webNotification = WebpushNotification.builder()
                .setTitle(title)
                .setBody(body)
                .setIcon("/icons/Icon-192.png")
                .build();

        return Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build())
                .putAllData(data)
                .setAndroidConfig(AndroidConfig.builder()
                        .setPriority(AndroidConfig.Priority.HIGH)
                        .setNotification(AndroidNotification.builder()
                                .setChannelId("maemoji_alerts")
                                .build())
                        .build())
                .setWebpushConfig(WebpushConfig.builder()
                        .putAllData(data)
                        .setNotification(webNotification)
                        .build())
                .build();
    }

    private String safeText(String value) {
        return value == null ? "" : value;
    }

    private String safeErrorCode(String errorCode) {
        return errorCode == null || errorCode.isBlank() ? "UNKNOWN" : errorCode;
    }

    private void deactivateInvalidToken(
            Long userId,
            UserDeviceTokenRecord device,
            FirebaseMessagingGateway.SendResult result,
            OffsetDateTime now
    ) {
        if (device == null || result == null || !isPermanentTokenError(result.errorCode())) {
            return;
        }
        portfolioInsightMapper.deactivateDeviceToken(userId, device.getFcmToken(), now);
    }

    private boolean isPermanentTokenError(String errorCode) {
        if (errorCode == null || errorCode.isBlank()) {
            return false;
        }
        return PERMANENT_TOKEN_ERROR_CODES.contains(errorCode.trim());
    }

    private String normalize(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }

    private String resolveFocusSection(UserAlertEventRecord alertEvent) {
        final String alertType = safeText(alertEvent == null ? null : alertEvent.getAlertType()).trim().toUpperCase();
        return resolveFocusSection(alertType);
    }

    private String resolveFocusSection(String alertType) {
        final String normalized = safeText(alertType).trim().toUpperCase(Locale.ROOT);
        return switch (normalized) {
            case "NEWS_WEAKENED" -> "NEWS";
            case "PRICE_RISK", "STATUS_CHANGED", "STATUS_DOWNGRADED" -> "RECOMMENDATION";
            default -> "TOP";
        };
    }

    private String normalizeAlertType(String rawAlertType) {
        final String normalized = safeText(rawAlertType).trim().toUpperCase(Locale.ROOT);
        return switch (normalized) {
            case "PRICE_RISK", "NEWS_WEAKENED", "STATUS_DOWNGRADED", "STATUS_CHANGED" -> normalized;
            default -> "STATUS_CHANGED";
        };
    }

    private String defaultTestTitle(String alertType) {
        return switch (alertType) {
            case "PRICE_RISK" -> "가격 흔들림 테스트";
            case "NEWS_WEAKENED" -> "뉴스 악화 테스트";
            case "STATUS_DOWNGRADED" -> "의견 하향 테스트";
            case "STATUS_CHANGED" -> "의견 변경 테스트";
            default -> "매모지 테스트 알림";
        };
    }

    private String defaultTestBody(String alertType) {
        return switch (alertType) {
            case "PRICE_RISK" -> "가격 흐름이 흔들리는 상황을 테스트로 보냈어요.";
            case "NEWS_WEAKENED" -> "관련 뉴스 분위기가 약해지는 상황을 테스트로 보냈어요.";
            case "STATUS_DOWNGRADED" -> "추천 의견이 하향되는 상황을 테스트로 보냈어요.";
            case "STATUS_CHANGED" -> "추천 의견 변화 알림 동작을 테스트로 보냈어요.";
            default -> "현재 기기에 테스트 푸시를 보냈어요.";
        };
    }

    public record PushDispatchPlan(
            Long userId,
            String notificationKind,
            String title,
            String body,
            Map<String, String> data,
            List<UserDeviceTokenRecord> targetDevices
    ) {
        public static PushDispatchPlan inAppOnly(Long userId, String notificationKind, String reason) {
            return new PushDispatchPlan(
                    userId,
                    notificationKind,
                    "",
                    reason,
                    Map.of(),
                    List.of()
            );
        }

        public boolean dispatchable() {
            return !targetDevices.isEmpty();
        }
    }

    public record PushDispatchResult(
            boolean dispatched,
            int targetDeviceCount,
            int successCount,
            int failureCount,
            String message
    ) {
        public static PushDispatchResult notDispatched(int targetDeviceCount, String message) {
            return new PushDispatchResult(false, targetDeviceCount, 0, 0, message);
        }
    }
}
