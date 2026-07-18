package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.UserAlertEventRecord;
import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;

@Service
public class PushNotificationPolicyService {

    private static final String DEFAULT_TIMEZONE = "Asia/Seoul";

    public boolean isImmediatePushEligible(
            UserAlertEventRecord alertEvent,
            UserNotificationPreferenceRecord preference
    ) {
        if (alertEvent == null || preference == null) {
            return false;
        }
        if (!Boolean.TRUE.equals(preference.getInstantAlertEnabled())) {
            return false;
        }

        return switch (safeUpper(alertEvent.getAlertType())) {
            case "STATUS_CHANGED", "STATUS_DOWNGRADED" ->
                    Boolean.TRUE.equals(preference.getStatusChangedAlertEnabled());
            case "NEWS_WEAKENED" -> Boolean.TRUE.equals(preference.getNewsWeakenedAlertEnabled());
            case "PRICE_RISK" -> Boolean.TRUE.equals(preference.getPriceRiskAlertEnabled());
            default -> false;
        };
    }

    public boolean isSuppressedByQuietHours(
            UserNotificationPreferenceRecord preference,
            OffsetDateTime now
    ) {
        if (preference == null
                || !Boolean.TRUE.equals(preference.getQuietHoursEnabled())
                || preference.getQuietHoursStart() == null
                || preference.getQuietHoursEnd() == null
                || now == null) {
            return false;
        }

        final ZoneId zoneId = resolveZone(preference.getTimezone());
        final LocalTime currentTime = now.atZoneSameInstant(zoneId).toLocalTime();
        final LocalTime start = preference.getQuietHoursStart();
        final LocalTime end = preference.getQuietHoursEnd();

        if (start.equals(end)) {
            return false;
        }
        if (start.isBefore(end)) {
            return !currentTime.isBefore(start) && currentTime.isBefore(end);
        }
        return !currentTime.isBefore(start) || currentTime.isBefore(end);
    }

    public boolean isWithinCooldown(
            UserAlertEventRecord alertEvent,
            OffsetDateTime lastSuccessfulSentAt,
            OffsetDateTime now
    ) {
        if (alertEvent == null || lastSuccessfulSentAt == null || now == null) {
            return false;
        }

        final Duration cooldown = cooldownFor(alertEvent.getAlertType());
        if (cooldown.isZero() || cooldown.isNegative()) {
            return false;
        }
        return lastSuccessfulSentAt.plus(cooldown).isAfter(now);
    }

    public boolean isWeeklyDigestEligible(UserNotificationPreferenceRecord preference) {
        return preference != null && Boolean.TRUE.equals(preference.getWeeklyDigestEnabled());
    }

    public String resolveNotificationKind(UserAlertEventRecord alertEvent) {
        final String alertType = alertEvent == null ? "" : safeUpper(alertEvent.getAlertType());
        if ("WEEKLY_REPORT_READY".equals(alertType)) {
            return "WEEKLY_DIGEST";
        }
        if ("STATUS_CHANGED".equals(alertType)
                || "STATUS_DOWNGRADED".equals(alertType)
                || "NEWS_WEAKENED".equals(alertType)
                || "PRICE_RISK".equals(alertType)) {
            return "IMMEDIATE";
        }
        return "IN_APP_ONLY";
    }

    private String safeUpper(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }

    private Duration cooldownFor(String alertType) {
        return switch (safeUpper(alertType)) {
            case "STATUS_CHANGED", "STATUS_DOWNGRADED" -> Duration.ofHours(8);
            case "NEWS_WEAKENED" -> Duration.ofHours(12);
            case "PRICE_RISK" -> Duration.ofHours(18);
            default -> Duration.ZERO;
        };
    }

    private ZoneId resolveZone(String timezone) {
        try {
            return ZoneId.of(
                    timezone == null || timezone.isBlank()
                            ? DEFAULT_TIMEZONE
                            : timezone.trim()
            );
        } catch (Exception ignored) {
            return ZoneId.of(DEFAULT_TIMEZONE);
        }
    }
}
