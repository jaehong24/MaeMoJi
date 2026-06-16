package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.PlatformTransactionManager;

import java.lang.reflect.Constructor;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class RecommendationFundamentalQualityRegressionTest {

    private RecommendationService recommendationService;
    private Class<?> priceSnapshotClass;

    @BeforeEach
    void setUp() throws Exception {
        final RecommendationTuningProperties tuningProperties = new RecommendationTuningProperties();
        recommendationService = new RecommendationService(
                mock(RecommendationMapper.class),
                new ObjectMapper(),
                mock(NewsSentimentService.class),
                new RecommendationScoreCalculator(tuningProperties),
                mock(StockPriceSnapshotMapper.class),
                tuningProperties,
                mock(PlatformTransactionManager.class)
        );

        for (Class<?> nestedClass : RecommendationService.class.getDeclaredClasses()) {
            if ("PriceSnapshot".equals(nestedClass.getSimpleName())) {
                priceSnapshotClass = nestedClass;
                break;
            }
        }
        assertThat(priceSnapshotClass).isNotNull();
    }

    @Test
    void representativeSamplesDoNotCollapseIntoHundredPointCluster() throws Exception {
        final Map<String, Integer> scores = new LinkedHashMap<>();
        scores.put("NVDA", scoreOf(snapshot(
                5_061_067.0,
                31.7084,
                6.5722,
                0.6547,
                0.6402,
                1.1166,
                0.0656
        )));
        scores.put("GOOGL", scoreOf(snapshot(
                4_519_631.5,
                28.2110,
                13.2414,
                0.1513,
                0.3270,
                0.3898,
                0.1890
        )));
        scores.put("NFLX", scoreOf(snapshot(
                328_168.56,
                24.5385,
                3.1670,
                0.1585,
                0.2972,
                0.4924,
                0.5379
        )));
        scores.put("AAPL", scoreOf(snapshot(
                4_384_323.0,
                35.7685,
                8.3324,
                0.0643,
                0.3264,
                1.4669,
                0.7955
        )));
        scores.put("AMZN", scoreOf(snapshot(
                2_671_420.5,
                29.4216,
                8.4518,
                0.1238,
                0.1150,
                0.2334,
                0.4750
        )));
        scores.put("COST", scoreOf(snapshot(
                440_057.38,
                49.7915,
                19.9089,
                0.0817,
                0.0382,
                0.2827,
                0.2457
        )));
        scores.put("TSLA", scoreOf(snapshot(
                1_544_165.8,
                399.8358,
                1.1985,
                -0.0293,
                0.0500,
                0.0479,
                0.1097
        )));

        assertThat(scores.values()).doesNotContain(100);
        assertThat(scores.get("NVDA")).isBetween(90, 95);
        assertThat(scores.get("GOOGL")).isBetween(80, 89);
        assertThat(scores.get("AMZN")).isBetween(70, 79);
        assertThat(scores.get("COST")).isBetween(55, 65);
        assertThat(scores.get("TSLA")).isLessThanOrEqualTo(45);

        assertThat(scores.get("NVDA")).isGreaterThan(scores.get("GOOGL"));
        assertThat(scores.get("GOOGL")).isGreaterThan(scores.get("AAPL"));
        assertThat(scores.get("AAPL")).isGreaterThan(scores.get("AMZN"));
        assertThat(scores.get("AMZN")).isGreaterThan(scores.get("COST"));
        assertThat(scores.get("COST")).isGreaterThan(scores.get("TSLA"));
    }

    @Test
    void exceptionalLeaderKeepsVisibleGapFromStrongMegaCaps() throws Exception {
        final int nvda = scoreOf(snapshot(
                5_061_067.0,
                31.7084,
                6.5722,
                0.6547,
                0.6402,
                1.1166,
                0.0656
        ));
        final int googl = scoreOf(snapshot(
                4_519_631.5,
                28.2110,
                13.2414,
                0.1513,
                0.3270,
                0.3898,
                0.1890
        ));
        final int amzn = scoreOf(snapshot(
                2_671_420.5,
                29.4216,
                8.4518,
                0.1238,
                0.1150,
                0.2334,
                0.4750
        ));

        assertThat(nvda - googl).isGreaterThanOrEqualTo(5);
        assertThat(googl - amzn).isGreaterThanOrEqualTo(8);
    }

    private Object snapshot(
            Double marketCap,
            Double perValue,
            Double epsTtm,
            Double revenueGrowthYoy,
            Double operatingMarginTtm,
            Double roeTtm,
            Double debtToEquityTtm
    ) throws Exception {
        final Constructor<?> constructor = priceSnapshotClass.getDeclaredConstructor(
                Double.class,
                Double.class,
                Double.class,
                BigDecimal.class,
                BigDecimal.class,
                BigDecimal.class,
                BigDecimal.class,
                BigDecimal.class,
                BigDecimal.class,
                BigDecimal.class
        );
        constructor.setAccessible(true);
        return constructor.newInstance(
                null,
                null,
                null,
                toBigDecimal(marketCap),
                toBigDecimal(perValue),
                toBigDecimal(epsTtm),
                toBigDecimal(revenueGrowthYoy),
                toBigDecimal(operatingMarginTtm),
                toBigDecimal(roeTtm),
                toBigDecimal(debtToEquityTtm)
        );
    }

    private int scoreOf(Object priceSnapshot) {
        final Object assessment =
                ReflectionTestUtils.invokeMethod(recommendationService, "resolveFundamentalQualityAssessment", priceSnapshot);
        assertThat(assessment).isNotNull();
        final Integer score = (Integer) ReflectionTestUtils.invokeMethod(assessment, "score");
        assertThat(score).isNotNull();
        return score;
    }

    private BigDecimal toBigDecimal(Double value) {
        return value == null ? null : BigDecimal.valueOf(value);
    }
}
