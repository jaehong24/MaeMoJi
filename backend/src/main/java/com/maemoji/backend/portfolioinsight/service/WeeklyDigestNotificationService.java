package com.maemoji.backend.portfolioinsight.service;

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
        for (UserDeviceTokenRecord device : plan.targetDevices()) {
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
        }

        try {
            final List<FirebaseMessagingGateway.SendResult> results = firebaseMessagingGateway.sendEach(messages);
            int successCount = 0;
            int failureCount = 0;
            for (int index = 0; index < results.size(); index++) {
                final FirebaseMessagingGateway.SendResult result = results.get(index);
                if (result.successful()) {
                    successCount++;
                } else {
                    failureCount++;
                    if (isPermanentTokenError(result.errorCode())) {
                        final UserDeviceTokenRecord device = plan.targetDevices().get(index);
                        portfolioInsightMapper.deactivateDeviceToken(userId, device.getFcmToken(), now);
                    }
                }
            }

            portfolioInsightMapper.updateWeeklyNotificationJobResult(
                    userId,
                    report.reportWeek(),
                    failureCount == 0 ? "SUCCESS" : "PARTIAL_SUCCESS",
                    plan.targetDevices().size(),
                    successCount,
                    failureCount,
                    now,
                    now,
                    null
            );

            return new WeeklyDigestDispatchResult(true, plan.targetDevices().size(), successCount, failureCount, null);
        } catch (Exception exception) {
            portfolioInsightMapper.updateWeeklyNotificationJobResult(
                    userId,
                    report.reportWeek(),
                    "FAILED",
                    plan.targetDevices().size(),
                    0,
                    plan.targetDevices().size(),
                    now,
                    now,
                    exception.getMessage()
            );
            return new WeeklyDigestDispatchResult(
                    false,
                    plan.targetDevices().size(),
                    0,
                    plan.targetDevices().size(),
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

    private boolean hasMeaningfulChange(WeeklyReportResponse report) {
        return report != null && (report.changedItemCount() > 0 || report.alertItemCount() > 0);
    }
}
