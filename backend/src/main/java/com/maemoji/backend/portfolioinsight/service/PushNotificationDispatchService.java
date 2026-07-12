package com.maemoji.backend.portfolioinsight.service;

import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
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
import java.util.Map;

@Service
public class PushNotificationDispatchService {

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

        if (!pushNotificationPolicyService.isImmediatePushEligible(alertEvent, preference)) {
            return PushDispatchPlan.inAppOnly(
                    userId,
                    pushNotificationPolicyService.resolveNotificationKind(alertEvent),
                    "현재 정책상 푸시 발송 대상이 아닙니다."
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
                        "alertType", safeText(alertEvent.getAlertType())
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
            messages.add(buildMessage(device.getFcmToken(), plan.title(), plan.body(), plan.data()));
        }

        if (messages.isEmpty()) {
            return PushDispatchResult.notDispatched(plan.targetDevices().size(), "이미 같은 푸시를 발송했습니다.");
        }

        final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));
        try {
            final List<String> messageIds = firebaseMessagingGateway.sendEach(messages);
            int successCount = 0;
            int failureCount = 0;

            for (int index = 0; index < messageIds.size(); index++) {
                final String messageId = messageIds.get(index);
                final String dedupeKey = dedupeKeys.get(index);
                if (messageId != null && !messageId.isBlank()) {
                    portfolioInsightMapper.updatePushNotificationDeliverySuccess(dedupeKey, messageId, now);
                    successCount++;
                } else {
                    portfolioInsightMapper.updatePushNotificationDeliveryFailure(
                            dedupeKey,
                            "UNKNOWN",
                            "메시지 ID를 받지 못했습니다.",
                            now
                    );
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

        final String title = normalize(request == null ? null : request.title(), "매모지 테스트 알림");
        final String body = normalize(request == null ? null : request.body(), "현재 기기에 테스트 푸시를 보냈어요.");
        final Map<String, String> data = Map.of(
                "type", "TEST_PUSH",
                "target", "SELF"
        );

        final List<Message> messages = activeDevices.stream()
                .map(device -> buildMessage(device.getFcmToken(), title, body, data))
                .toList();

        try {
            final List<String> messageIds = firebaseMessagingGateway.sendEach(messages);
            final int successCount = (int) messageIds.stream().filter(id -> id != null && !id.isBlank()).count();
            final int failureCount = messageIds.size() - successCount;
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
                .build();
    }

    private String safeText(String value) {
        return value == null ? "" : value;
    }

    private String normalize(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
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
