package com.maemoji.backend.portfolioinsight.mapper;

import com.maemoji.backend.portfolioinsight.domain.PortfolioReasonRecord;
import com.maemoji.backend.portfolioinsight.domain.RecommendationTrendRow;
import com.maemoji.backend.portfolioinsight.domain.UserDeviceTokenRecord;
import com.maemoji.backend.portfolioinsight.domain.UserAlertEventRecord;
import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import com.maemoji.backend.portfolioinsight.domain.WeeklyReportItemRecord;
import com.maemoji.backend.portfolioinsight.domain.WeeklyReportRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

@Mapper
public interface PortfolioInsightMapper {

    Long findOwnedActivePortfolioItemId(
            @Param("userId") Long userId,
            @Param("portfolioItemId") Long portfolioItemId
    );

    void deletePortfolioReasons(@Param("portfolioItemId") Long portfolioItemId);

    void insertPortfolioReason(
            @Param("portfolioItemId") Long portfolioItemId,
            @Param("reasonCode") String reasonCode,
            @Param("displayOrder") int displayOrder
    );

    List<PortfolioReasonRecord> findPortfolioReasons(
            @Param("userId") Long userId,
            @Param("portfolioItemId") Long portfolioItemId
    );

    WeeklyReportRecord findLatestWeeklyReportByUserId(@Param("userId") Long userId);

    List<WeeklyReportRecord> findWeeklyReportsByUserId(@Param("userId") Long userId);

    List<WeeklyReportItemRecord> findWeeklyReportItemsByReportId(@Param("reportId") Long reportId);

    List<RecommendationTrendRow> findRecommendationTrendRowsByUserId(@Param("userId") Long userId);

    void deleteWeeklyReportItemsByReportId(@Param("reportId") Long reportId);

    void deleteWeeklyReportByUserIdAndWeek(
            @Param("userId") Long userId,
            @Param("reportWeek") LocalDate reportWeek
    );

    void insertWeeklyReport(
            @Param("userId") Long userId,
            @Param("reportWeek") LocalDate reportWeek,
            @Param("generatedAt") OffsetDateTime generatedAt,
            @Param("headline") String headline,
            @Param("summary") String summary,
            @Param("changedItemCount") int changedItemCount,
            @Param("alertItemCount") int alertItemCount,
            @Param("positiveItemCount") int positiveItemCount,
            @Param("negativeItemCount") int negativeItemCount
    );

    Long findWeeklyReportIdByUserIdAndWeek(
            @Param("userId") Long userId,
            @Param("reportWeek") LocalDate reportWeek
    );

    void insertWeeklyReportItem(
            @Param("reportId") Long reportId,
            @Param("portfolioItemId") Long portfolioItemId,
            @Param("stockId") Long stockId,
            @Param("currentStatus") String currentStatus,
            @Param("previousStatus") String previousStatus,
            @Param("scoreDelta") int scoreDelta,
            @Param("headlineLabel") String headlineLabel,
            @Param("changeType") String changeType,
            @Param("summary") String summary,
            @Param("displayOrder") int displayOrder
    );

    void insertAlertEvent(
            @Param("userId") Long userId,
            @Param("portfolioItemId") Long portfolioItemId,
            @Param("stockId") Long stockId,
            @Param("alertType") String alertType,
            @Param("title") String title,
            @Param("body") String body,
            @Param("dedupeKey") String dedupeKey,
            @Param("sentAt") OffsetDateTime sentAt
    );

    List<UserAlertEventRecord> findAlertsByUserId(@Param("userId") Long userId);

    Optional<UserAlertEventRecord> findAlertById(
            @Param("userId") Long userId,
            @Param("alertId") Long alertId
    );

    UserAlertEventRecord findAlertByDedupeKey(
            @Param("userId") Long userId,
            @Param("dedupeKey") String dedupeKey
    );

    int markAlertRead(
            @Param("userId") Long userId,
            @Param("alertId") Long alertId
    );

    void ensureNotificationPreferenceRow(
            @Param("userId") Long userId,
            @Param("timezone") String timezone,
            @Param("weeklyDigestDay") String weeklyDigestDay,
            @Param("weeklyDigestTime") LocalTime weeklyDigestTime
    );

    UserNotificationPreferenceRecord findNotificationPreferenceByUserId(@Param("userId") Long userId);

    int updateNotificationPreference(
            @Param("userId") Long userId,
            @Param("instantAlertEnabled") boolean instantAlertEnabled,
            @Param("weeklyDigestEnabled") boolean weeklyDigestEnabled,
            @Param("priceRiskAlertEnabled") boolean priceRiskAlertEnabled,
            @Param("newsWeakenedAlertEnabled") boolean newsWeakenedAlertEnabled,
            @Param("statusChangedAlertEnabled") boolean statusChangedAlertEnabled,
            @Param("quietHoursEnabled") boolean quietHoursEnabled,
            @Param("quietHoursStart") LocalTime quietHoursStart,
            @Param("quietHoursEnd") LocalTime quietHoursEnd,
            @Param("timezone") String timezone,
            @Param("weeklyDigestDay") String weeklyDigestDay,
            @Param("weeklyDigestTime") LocalTime weeklyDigestTime
    );

    void upsertDeviceToken(
            @Param("userId") Long userId,
            @Param("devicePlatform") String devicePlatform,
            @Param("deviceIdentifier") String deviceIdentifier,
            @Param("fcmToken") String fcmToken,
            @Param("appVersion") String appVersion,
            @Param("pushEnabled") boolean pushEnabled,
            @Param("lastSeenAt") OffsetDateTime lastSeenAt
    );

    List<UserDeviceTokenRecord> findDeviceTokensByUserId(@Param("userId") Long userId);

    UserDeviceTokenRecord findDeviceTokenByUserIdAndToken(
            @Param("userId") Long userId,
            @Param("fcmToken") String fcmToken
    );

    int deactivateDeviceToken(
            @Param("userId") Long userId,
            @Param("fcmToken") String fcmToken,
            @Param("deactivatedAt") OffsetDateTime deactivatedAt
    );

    int insertPushNotificationDelivery(
            @Param("alertEventId") Long alertEventId,
            @Param("userId") Long userId,
            @Param("deviceTokenId") Long deviceTokenId,
            @Param("notificationKind") String notificationKind,
            @Param("alertType") String alertType,
            @Param("dedupeKey") String dedupeKey,
            @Param("title") String title,
            @Param("body") String body,
            @Param("payloadJson") String payloadJson
    );

    int updatePushNotificationDeliverySuccess(
            @Param("dedupeKey") String dedupeKey,
            @Param("providerMessageId") String providerMessageId,
            @Param("sentAt") OffsetDateTime sentAt
    );

    int updatePushNotificationDeliveryFailure(
            @Param("dedupeKey") String dedupeKey,
            @Param("providerErrorCode") String providerErrorCode,
            @Param("providerErrorMessage") String providerErrorMessage,
            @Param("sentAt") OffsetDateTime sentAt
    );

    int insertWeeklyNotificationJobIfAbsent(
            @Param("userId") Long userId,
            @Param("reportId") Long reportId,
            @Param("reportWeek") LocalDate reportWeek,
            @Param("scheduledAt") OffsetDateTime scheduledAt
    );

    int updateWeeklyNotificationJobResult(
            @Param("userId") Long userId,
            @Param("reportWeek") LocalDate reportWeek,
            @Param("jobStatus") String jobStatus,
            @Param("targetDeviceCount") int targetDeviceCount,
            @Param("successCount") int successCount,
            @Param("failureCount") int failureCount,
            @Param("startedAt") OffsetDateTime startedAt,
            @Param("completedAt") OffsetDateTime completedAt,
            @Param("errorMessage") String errorMessage
    );
}
