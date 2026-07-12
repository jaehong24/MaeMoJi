package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.UserAlertEventRecord;
import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import org.springframework.stereotype.Service;

@Service
public class PushNotificationPolicyService {

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
            case "STATUS_CHANGED" -> Boolean.TRUE.equals(preference.getStatusChangedAlertEnabled());
            case "NEWS_WEAKENED" -> Boolean.TRUE.equals(preference.getNewsWeakenedAlertEnabled());
            case "PRICE_RISK" -> Boolean.TRUE.equals(preference.getPriceRiskAlertEnabled());
            default -> false;
        };
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
                || "NEWS_WEAKENED".equals(alertType)
                || "PRICE_RISK".equals(alertType)) {
            return "IMMEDIATE";
        }
        return "IN_APP_ONLY";
    }

    private String safeUpper(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }
}
