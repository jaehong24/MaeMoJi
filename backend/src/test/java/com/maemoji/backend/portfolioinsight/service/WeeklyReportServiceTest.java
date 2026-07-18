package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.RecommendationTrendRow;
import com.maemoji.backend.portfolioinsight.domain.UserAlertEventRecord;
import com.maemoji.backend.portfolioinsight.domain.WeeklyReportRecord;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class WeeklyReportServiceTest {

    private final PortfolioInsightMapper portfolioInsightMapper = mock(PortfolioInsightMapper.class);
    private final PushNotificationDispatchService pushNotificationDispatchService =
            mock(PushNotificationDispatchService.class);
    private final WeeklyDigestNotificationService weeklyDigestNotificationService =
            mock(WeeklyDigestNotificationService.class);
    private final WeeklyReportService weeklyReportService = new WeeklyReportService(
            portfolioInsightMapper,
            pushNotificationDispatchService,
            weeklyDigestNotificationService
    );

    @Test
    void 일일뉴스악화이벤트를새로만든경우에만푸시를발송한다() {
        final RecommendationTrendRow current = row(1L, "AMD", 61, 45, 60, 62);
        current.setStockId(10L);
        current.setRowNumber(1);
        final RecommendationTrendRow previous = row(1L, "AMD", 66, 60, 62, 64);
        previous.setStockId(10L);
        previous.setRowNumber(2);
        final UserAlertEventRecord alertEvent = new UserAlertEventRecord();
        alertEvent.setId(100L);
        alertEvent.setPortfolioItemId(1L);
        alertEvent.setStockId(10L);
        alertEvent.setAlertType("NEWS_WEAKENED");
        alertEvent.setTitle("AMD · 뉴스 악화");
        alertEvent.setBody("최근 뉴스 분위기가 약해졌어요.");

        when(portfolioInsightMapper.findRecommendationTrendRowsByUserId(7L))
                .thenReturn(List.of(current, previous));
        when(portfolioInsightMapper.insertAlertEvent(
                eq(7L), eq(1L), eq(10L), eq("NEWS_WEAKENED"),
                anyString(), anyString(), anyString(), any()
        )).thenReturn(1);
        when(portfolioInsightMapper.findAlertByDedupeKey(eq(7L), anyString()))
                .thenReturn(alertEvent);
        when(pushNotificationDispatchService.dispatchImmediate(7L, alertEvent))
                .thenReturn(new PushNotificationDispatchService.PushDispatchResult(true, 2, 2, 0, null));

        final WeeklyReportService.ImmediateAlertProcessingResult result =
                weeklyReportService.processImmediateAlerts(7L, LocalDate.of(2026, 7, 18));

        assertThat(result.detectedCount()).isEqualTo(1);
        assertThat(result.createdCount()).isEqualTo(1);
        assertThat(result.pushSuccessCount()).isEqualTo(2);
        verify(pushNotificationDispatchService).dispatchImmediate(7L, alertEvent);
    }

    @Test
    void 같은날이미저장된이벤트는푸시를다시발송하지않는다() {
        final RecommendationTrendRow current = row(2L, "TSLA", 55, 50, 38, 42);
        current.setStockId(20L);
        current.setRowNumber(1);
        final RecommendationTrendRow previous = row(2L, "TSLA", 63, 51, 55, 58);
        previous.setStockId(20L);
        previous.setRowNumber(2);

        when(portfolioInsightMapper.findRecommendationTrendRowsByUserId(8L))
                .thenReturn(List.of(current, previous));
        when(portfolioInsightMapper.insertAlertEvent(
                eq(8L), eq(2L), eq(20L), eq("PRICE_RISK"),
                anyString(), anyString(), anyString(), any()
        )).thenReturn(0);

        final WeeklyReportService.ImmediateAlertProcessingResult result =
                weeklyReportService.processImmediateAlerts(8L, LocalDate.of(2026, 7, 18));

        assertThat(result.detectedCount()).isEqualTo(1);
        assertThat(result.createdCount()).isZero();
        verify(pushNotificationDispatchService, never()).dispatchImmediate(any(), any());
    }

    @Test
    void buildTrendMarksPriceRiskWhenCurrentPriceScoresAreAlreadyWeak() throws Exception {
        final RecommendationTrendRow previous = row(1L, "AMD", 67, 62, 58, 70);
        final RecommendationTrendRow current = row(1L, "AMD", 63, 61, 44, 47);

        final Object trend = ReflectionTestUtils.invokeMethod(
                weeklyReportService,
                "buildTrend",
                current,
                previous
        );

        final String changeType = (String) trend.getClass().getDeclaredMethod("changeType").invoke(trend);
        final String headline = (String) trend.getClass().getDeclaredMethod("headlineLabel").invoke(trend);

        assertThat(changeType).isEqualTo("PRICE_RISK");
        assertThat(headline).isEqualTo("가격 흔들림");
    }

    @Test
    void buildTrendKeepsMildDriftOutOfPriceRiskWhenCurrentScoresStayHealthy() throws Exception {
        final RecommendationTrendRow previous = row(1L, "MSFT", 71, 65, 71, 78);
        final RecommendationTrendRow current = row(1L, "MSFT", 69, 64, 66, 72);

        final Object trend = ReflectionTestUtils.invokeMethod(
                weeklyReportService,
                "buildTrend",
                current,
                previous
        );

        final String changeType = (String) trend.getClass().getDeclaredMethod("changeType").invoke(trend);

        assertThat(changeType).isNotEqualTo("PRICE_RISK");
    }

    @Test
    void buildTrendKeepsSupplementalPriceRiskMessageWhenStatusChangedFirst() throws Exception {
        final RecommendationTrendRow previous = row(1L, "META", 44, 50, 49, 54);
        previous.setRecommendationStatus("REDUCE");
        final RecommendationTrendRow current = row(1L, "META", 61, 50, 40, 43);
        current.setRecommendationStatus("MAINTAIN");

        final Object trend = ReflectionTestUtils.invokeMethod(
                weeklyReportService,
                "buildTrend",
                current,
                previous
        );

        final var changeTypeMethod = trend.getClass().getDeclaredMethod("changeType");
        changeTypeMethod.setAccessible(true);
        final var summaryMethod = trend.getClass().getDeclaredMethod("summary");
        summaryMethod.setAccessible(true);
        final String changeType = (String) changeTypeMethod.invoke(trend);
        final String summary = (String) summaryMethod.invoke(trend);

        assertThat(changeType).isEqualTo("STATUS_REBALANCED");
        assertThat(summary).contains("가격 흐름도 함께 흔들려");
    }

    @Test
    void 핵심자료가비어있으면변화를억지로판단하지않는다() throws Exception {
        final RecommendationTrendRow previous = row(3L, "NEW", 70, 60, 70, 72);
        final RecommendationTrendRow current = row(3L, "NEW", 45, 40, null, null);
        current.setFundamentalQualityScore(null);
        current.setRecommendationStatus("REDUCE");

        final Object trend = ReflectionTestUtils.invokeMethod(
                weeklyReportService,
                "buildTrend",
                current,
                previous
        );

        final var changeTypeMethod = trend.getClass().getDeclaredMethod("changeType");
        changeTypeMethod.setAccessible(true);
        final var headlineMethod = trend.getClass().getDeclaredMethod("headlineLabel");
        headlineMethod.setAccessible(true);

        assertThat(changeTypeMethod.invoke(trend)).isEqualTo("DATA_PENDING");
        assertThat(headlineMethod.invoke(trend)).isEqualTo("자료 수집 중");
    }

    @Test
    void 주간리포트생성은즉시알림을중복생성하지않는다() {
        final RecommendationTrendRow current = row(4L, "AMD", 55, 40, 42, 44);
        current.setStockId(40L);
        current.setRowNumber(1);
        current.setRecommendationStatus("REDUCE");
        final RecommendationTrendRow previous = row(4L, "AMD", 70, 60, 68, 70);
        previous.setStockId(40L);
        previous.setRowNumber(2);
        previous.setRecommendationStatus("MAINTAIN");

        final WeeklyReportRecord report = new WeeklyReportRecord();
        report.setId(90L);
        report.setReportWeek(LocalDate.now().minusDays(LocalDate.now().getDayOfWeek().getValue() - 1L));
        report.setHeadline("이번 주 다시 볼 종목이 1개 있어요");
        report.setSummary("주의해서 다시 볼 종목 1개의 이번 주 변화를 정리했어요.");
        report.setChangedItemCount(1);
        report.setAlertItemCount(1);
        report.setPositiveItemCount(0);
        report.setNegativeItemCount(1);

        when(portfolioInsightMapper.findRecommendationTrendRowsByUserId(9L))
                .thenReturn(List.of(current, previous));
        when(portfolioInsightMapper.findWeeklyReportIdByUserIdAndWeek(eq(9L), any()))
                .thenReturn(90L);
        when(portfolioInsightMapper.findLatestWeeklyReportByUserId(9L)).thenReturn(report);
        when(portfolioInsightMapper.findWeeklyReportItemsByReportId(90L)).thenReturn(List.of());

        weeklyReportService.generateLatestReport(9L);

        verify(portfolioInsightMapper, never()).insertAlertEvent(
                any(), any(), any(), anyString(), anyString(), anyString(), anyString(), any()
        );
        verify(weeklyDigestNotificationService).dispatchWeeklyDigest(eq(9L), any());
    }

    @Test
    void 이번주리포트가이미있으면다시생성하지않는다() {
        final WeeklyReportRecord report = new WeeklyReportRecord();
        report.setId(100L);
        report.setReportWeek(LocalDate.now().with(java.time.DayOfWeek.MONDAY));
        report.setHeadline("이번 주 리포트");
        report.setSummary("변화를 정리했어요.");
        report.setChangedItemCount(0);
        report.setAlertItemCount(0);
        report.setPositiveItemCount(0);
        report.setNegativeItemCount(0);
        when(portfolioInsightMapper.findWeeklyReportIdByUserIdAndWeek(eq(10L), any()))
                .thenReturn(100L);
        when(portfolioInsightMapper.findLatestWeeklyReportByUserId(10L)).thenReturn(report);
        when(portfolioInsightMapper.findWeeklyReportItemsByReportId(100L)).thenReturn(List.of());

        final boolean generated = weeklyReportService.generateCurrentWeekReportIfAbsent(10L);

        assertThat(generated).isFalse();
        verify(portfolioInsightMapper, never()).findRecommendationTrendRowsByUserId(10L);
        verify(weeklyDigestNotificationService).dispatchWeeklyDigest(eq(10L), any());
    }

    private RecommendationTrendRow row(
            Long portfolioItemId,
            String companyName,
            Integer engineScore,
            Integer newsScore,
            Integer priceMomentumScore,
            Integer priceStabilityScore
    ) {
        final RecommendationTrendRow row = new RecommendationTrendRow();
        row.setPortfolioItemId(portfolioItemId);
        row.setCompanyName(companyName);
        row.setRecommendationStatus("MAINTAIN");
        row.setEngineScore(engineScore);
        row.setNewsScore(newsScore);
        row.setPriceMomentumScore(priceMomentumScore);
        row.setPriceStabilityScore(priceStabilityScore);
        row.setFundamentalQualityScore(72);
        return row;
    }
}
