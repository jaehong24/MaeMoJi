package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
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
                mock(StockPriceSnapshotBatchService.class),
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

        assertThat(scores.values()).withFailMessage(scores.toString()).doesNotContain(100);
        assertThat(scores.get("NVDA")).withFailMessage(scores.toString()).isBetween(88, 92);
        assertThat(scores.get("GOOGL")).withFailMessage(scores.toString()).isBetween(78, 84);
        assertThat(scores.get("AMZN")).withFailMessage(scores.toString()).isBetween(70, 78);
        assertThat(scores.get("COST")).withFailMessage(scores.toString()).isBetween(60, 70);
        assertThat(scores.get("TSLA")).withFailMessage(scores.toString()).isLessThanOrEqualTo(60);

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

        assertThat(nvda - googl).withFailMessage("nvda=%s, googl=%s, amzn=%s", nvda, googl, amzn).isGreaterThanOrEqualTo(5);
        assertThat(googl - amzn).withFailMessage("nvda=%s, googl=%s, amzn=%s", nvda, googl, amzn).isGreaterThanOrEqualTo(6);
    }

    @Test
    void valuationSeparatesPremiumGrowthFromReasonableCashGenerators() throws Exception {
        final int tslaValuation = valuationScoreOf(snapshot(
                1_544_165.8,
                399.8358,
                1.1985,
                -0.0293,
                0.0500,
                0.0479,
                0.1097
        ));
        final int googlValuation = valuationScoreOf(snapshot(
                4_519_631.5,
                28.2110,
                13.2414,
                0.1513,
                0.3270,
                0.3898,
                0.1890
        ));
        final int costValuation = valuationScoreOf(snapshot(
                440_057.38,
                49.7915,
                19.9089,
                0.0817,
                0.0382,
                0.2827,
                0.2457
        ));

        assertThat(googlValuation).isGreaterThan(costValuation);
        assertThat(costValuation).isGreaterThan(tslaValuation);
    }

    @Test
    void qualityOfGrowthSeparatesEfficientGrowthFromWeakGrowth() throws Exception {
        final int nvdaQualityOfGrowth = qualityOfGrowthScoreOf(snapshot(
                5_061_067.0,
                31.7084,
                6.5722,
                0.6547,
                0.6402,
                1.1166,
                0.0656
        ));
        final int amznQualityOfGrowth = qualityOfGrowthScoreOf(snapshot(
                2_671_420.5,
                29.4216,
                8.4518,
                0.1238,
                0.1150,
                0.2334,
                0.4750
        ));
        final int tslaQualityOfGrowth = qualityOfGrowthScoreOf(snapshot(
                1_544_165.8,
                399.8358,
                1.1985,
                -0.0293,
                0.0500,
                0.0479,
                0.1097
        ));

        assertThat(nvdaQualityOfGrowth).isGreaterThan(amznQualityOfGrowth);
        assertThat(amznQualityOfGrowth).isGreaterThan(tslaQualityOfGrowth);
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
        final Constructor<?> constructor = priceSnapshotClass.getDeclaredConstructors()[0];
        constructor.setAccessible(true);
        final Object[] args = new Object[constructor.getParameterCount()];
        args[3] = toBigDecimal(marketCap);
        args[4] = toBigDecimal(perValue);
        args[5] = toBigDecimal(epsTtm);
        args[6] = toBigDecimal(revenueGrowthYoy);
        args[9] = toBigDecimal(operatingMarginTtm);
        args[10] = toBigDecimal(roeTtm);
        args[13] = toBigDecimal(debtToEquityTtm);
        return constructor.newInstance(args);
    }

    private int scoreOf(Object priceSnapshot) {
        final Object assessment = assessmentOf(priceSnapshot);
        assertThat(assessment).isNotNull();
        final Integer score = (Integer) ReflectionTestUtils.invokeMethod(assessment, "score");
        assertThat(score).isNotNull();
        return score;
    }

    private int valuationScoreOf(Object priceSnapshot) {
        final Object assessment = assessmentOf(priceSnapshot);
        assertThat(assessment).isNotNull();
        final Integer score = (Integer) ReflectionTestUtils.invokeMethod(assessment, "valuationScore");
        assertThat(score).isNotNull();
        return score;
    }

    private int qualityOfGrowthScoreOf(Object priceSnapshot) {
        final Object assessment = assessmentOf(priceSnapshot);
        assertThat(assessment).isNotNull();
        final Integer score = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveQualityOfGrowthScore",
                assessment
        );
        assertThat(score).isNotNull();
        return score;
    }

    private Object assessmentOf(Object priceSnapshot) {
        return ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveFundamentalQualityAssessment",
                priceSnapshot
        );
    }

    private BigDecimal toBigDecimal(Double value) {
        return value == null ? null : BigDecimal.valueOf(value);
    }
}
