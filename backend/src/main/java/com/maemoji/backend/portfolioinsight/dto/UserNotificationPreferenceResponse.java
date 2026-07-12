package com.maemoji.backend.portfolioinsight.dto;

import java.time.LocalTime;

public record UserNotificationPreferenceResponse(
        boolean instantAlertEnabled,
        boolean weeklyDigestEnabled,
        boolean priceRiskAlertEnabled,
        boolean newsWeakenedAlertEnabled,
        boolean statusChangedAlertEnabled,
        boolean quietHoursEnabled,
        LocalTime quietHoursStart,
        LocalTime quietHoursEnd,
        String timezone,
        String weeklyDigestDay,
        LocalTime weeklyDigestTime
) {
}
