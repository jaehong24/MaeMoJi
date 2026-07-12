package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.UserDeviceTokenRecord;
import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import com.maemoji.backend.portfolioinsight.dto.UserDeviceTokenDeactivateRequest;
import com.maemoji.backend.portfolioinsight.dto.UserDeviceTokenResponse;
import com.maemoji.backend.portfolioinsight.dto.UserDeviceTokenUpsertRequest;
import com.maemoji.backend.portfolioinsight.dto.UserNotificationPreferenceResponse;
import com.maemoji.backend.portfolioinsight.dto.UserNotificationPreferenceUpdateRequest;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;

@Service
public class PushNotificationSettingsService {

    public static final String DEFAULT_TIMEZONE = "Asia/Seoul";
    public static final String DEFAULT_WEEKLY_DIGEST_DAY = "MONDAY";
    public static final LocalTime DEFAULT_WEEKLY_DIGEST_TIME = LocalTime.of(8, 30);

    private final PortfolioInsightMapper portfolioInsightMapper;

    public PushNotificationSettingsService(PortfolioInsightMapper portfolioInsightMapper) {
        this.portfolioInsightMapper = portfolioInsightMapper;
    }

    @Transactional
    public UserNotificationPreferenceResponse getPreferences(Long userId) {
        ensurePreferenceRow(userId);
        final UserNotificationPreferenceRecord record = portfolioInsightMapper.findNotificationPreferenceByUserId(userId);
        return toPreferenceResponse(record);
    }

    @Transactional
    public UserNotificationPreferenceResponse updatePreferences(
            Long userId,
            UserNotificationPreferenceUpdateRequest request
    ) {
        ensurePreferenceRow(userId);

        final String timezone = normalizeTimezone(request.timezone());
        final String weeklyDigestDay = normalizeWeeklyDigestDay(request.weeklyDigestDay());
        final LocalTime weeklyDigestTime = parseTime(request.weeklyDigestTime(), "주간 리포트 시간을 다시 확인해 주세요.");
        final LocalTime quietHoursStart = parseNullableTime(request.quietHoursStart(), "방해 금지 시작 시간을 다시 확인해 주세요.");
        final LocalTime quietHoursEnd = parseNullableTime(request.quietHoursEnd(), "방해 금지 종료 시간을 다시 확인해 주세요.");

        if (Boolean.TRUE.equals(request.quietHoursEnabled())
                && (quietHoursStart == null || quietHoursEnd == null)) {
            throw new IllegalArgumentException("방해 금지를 켜면 시작 시간과 종료 시간을 함께 입력해 주세요.");
        }

        portfolioInsightMapper.updateNotificationPreference(
                userId,
                request.instantAlertEnabled(),
                request.weeklyDigestEnabled(),
                request.priceRiskAlertEnabled(),
                request.newsWeakenedAlertEnabled(),
                request.statusChangedAlertEnabled(),
                request.quietHoursEnabled(),
                quietHoursStart,
                quietHoursEnd,
                timezone,
                weeklyDigestDay,
                weeklyDigestTime
        );

        return getPreferences(userId);
    }

    public List<UserDeviceTokenResponse> getDevices(Long userId) {
        return portfolioInsightMapper.findDeviceTokensByUserId(userId).stream()
                .map(this::toDeviceResponse)
                .toList();
    }

    @Transactional
    public UserDeviceTokenResponse upsertDevice(Long userId, UserDeviceTokenUpsertRequest request) {
        final String devicePlatform = normalizeDevicePlatform(request.devicePlatform());
        final String fcmToken = normalizeRequiredText(request.fcmToken(), "FCM 토큰을 입력해 주세요.");
        final String deviceIdentifier = normalizeNullableText(request.deviceIdentifier());
        final String appVersion = normalizeNullableText(request.appVersion());
        final boolean pushEnabled = request.pushEnabled() == null || request.pushEnabled();
        final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(DEFAULT_TIMEZONE));

        portfolioInsightMapper.upsertDeviceToken(
                userId,
                devicePlatform,
                deviceIdentifier,
                fcmToken,
                appVersion,
                pushEnabled,
                now
        );

        final UserDeviceTokenRecord record = portfolioInsightMapper.findDeviceTokenByUserIdAndToken(userId, fcmToken);
        if (record == null) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "디바이스 토큰 저장에 실패했습니다.");
        }
        return toDeviceResponse(record);
    }

    @Transactional
    public void deactivateDevice(Long userId, UserDeviceTokenDeactivateRequest request) {
        final String fcmToken = normalizeRequiredText(request.fcmToken(), "비활성화할 FCM 토큰을 입력해 주세요.");
        final int updated = portfolioInsightMapper.deactivateDeviceToken(userId, fcmToken, OffsetDateTime.now(ZoneId.of(DEFAULT_TIMEZONE)));
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "비활성화할 디바이스 토큰을 찾지 못했습니다.");
        }
    }

    private void ensurePreferenceRow(Long userId) {
        portfolioInsightMapper.ensureNotificationPreferenceRow(
                userId,
                DEFAULT_TIMEZONE,
                DEFAULT_WEEKLY_DIGEST_DAY,
                DEFAULT_WEEKLY_DIGEST_TIME
        );
    }

    private UserNotificationPreferenceResponse toPreferenceResponse(UserNotificationPreferenceRecord record) {
        return new UserNotificationPreferenceResponse(
                Boolean.TRUE.equals(record.getInstantAlertEnabled()),
                Boolean.TRUE.equals(record.getWeeklyDigestEnabled()),
                Boolean.TRUE.equals(record.getPriceRiskAlertEnabled()),
                Boolean.TRUE.equals(record.getNewsWeakenedAlertEnabled()),
                Boolean.TRUE.equals(record.getStatusChangedAlertEnabled()),
                Boolean.TRUE.equals(record.getQuietHoursEnabled()),
                record.getQuietHoursStart(),
                record.getQuietHoursEnd(),
                record.getTimezone(),
                record.getWeeklyDigestDay(),
                record.getWeeklyDigestTime()
        );
    }

    private UserDeviceTokenResponse toDeviceResponse(UserDeviceTokenRecord record) {
        return new UserDeviceTokenResponse(
                record.getId(),
                record.getDevicePlatform(),
                record.getDeviceIdentifier(),
                record.getAppVersion(),
                Boolean.TRUE.equals(record.getPushEnabled()),
                Boolean.TRUE.equals(record.getIsActive()),
                record.getLastSeenAt(),
                record.getCreatedAt(),
                record.getUpdatedAt()
        );
    }

    private String normalizeTimezone(String timezone) {
        final String normalized = normalizeRequiredText(timezone, "시간대를 입력해 주세요.");
        try {
            ZoneId.of(normalized);
            return normalized;
        } catch (Exception exception) {
            throw new IllegalArgumentException("지원하지 않는 시간대입니다.");
        }
    }

    private String normalizeWeeklyDigestDay(String weeklyDigestDay) {
        final String normalized = normalizeRequiredText(weeklyDigestDay, "주간 리포트 요일을 입력해 주세요.")
                .toUpperCase();
        try {
            DayOfWeek.valueOf(normalized);
            return normalized;
        } catch (Exception exception) {
            throw new IllegalArgumentException("주간 리포트 요일 형식이 올바르지 않습니다.");
        }
    }

    private String normalizeDevicePlatform(String devicePlatform) {
        final String normalized = normalizeRequiredText(devicePlatform, "디바이스 플랫폼을 입력해 주세요.")
                .toUpperCase();
        return switch (normalized) {
            case "ANDROID", "IOS", "WEB" -> normalized;
            default -> throw new IllegalArgumentException("지원하지 않는 디바이스 플랫폼입니다.");
        };
    }

    private String normalizeRequiredText(String value, String message) {
        final String normalized = (value == null ? "" : value.trim());
        if (normalized.isEmpty()) {
            throw new IllegalArgumentException(message);
        }
        return normalized;
    }

    private String normalizeNullableText(String value) {
        final String normalized = value == null ? "" : value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private LocalTime parseTime(String value, String message) {
        try {
            return LocalTime.parse(normalizeRequiredText(value, message));
        } catch (Exception exception) {
            throw new IllegalArgumentException(message);
        }
    }

    private LocalTime parseNullableTime(String value, String message) {
        final String normalized = normalizeNullableText(value);
        if (normalized == null) {
            return null;
        }
        try {
            return LocalTime.parse(normalized);
        } catch (Exception exception) {
            throw new IllegalArgumentException(message);
        }
    }
}
