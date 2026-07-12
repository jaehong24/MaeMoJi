package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.RecommendationTrendRow;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class WeeklyReportServiceTest {

    private final WeeklyReportService weeklyReportService = new WeeklyReportService(
            mock(PortfolioInsightMapper.class),
            mock(PushNotificationDispatchService.class),
            mock(WeeklyDigestNotificationService.class)
    );

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
