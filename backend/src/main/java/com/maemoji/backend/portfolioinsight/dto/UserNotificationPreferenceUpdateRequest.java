package com.maemoji.backend.portfolioinsight.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record UserNotificationPreferenceUpdateRequest(
        @NotNull Boolean instantAlertEnabled,
        @NotNull Boolean weeklyDigestEnabled,
        @NotNull Boolean priceRiskAlertEnabled,
        @NotNull Boolean newsWeakenedAlertEnabled,
        @NotNull Boolean statusChangedAlertEnabled,
        @NotNull Boolean quietHoursEnabled,
        String quietHoursStart,
        String quietHoursEnd,
        @NotBlank(message = "시간대를 입력해 주세요.") String timezone,
        @NotBlank(message = "주간 리포트 요일을 입력해 주세요.") String weeklyDigestDay,
        @NotBlank(message = "주간 리포트 시간을 입력해 주세요.") String weeklyDigestTime
) {
}
