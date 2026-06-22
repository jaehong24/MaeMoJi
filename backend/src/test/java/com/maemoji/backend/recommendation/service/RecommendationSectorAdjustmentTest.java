package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import com.maemoji.backend.recommendation.domain.RecommendationTarget;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.PlatformTransactionManager;

import java.lang.reflect.Constructor;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class RecommendationSectorAdjustmentTest {

    private RecommendationService recommendationService;
    private Class<?> priceSnapshotClass;

    @BeforeEach
    void setUp() {
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
    void cyclicalEnergyNamesReceiveSmallSupportWhenValuationAndStabilityAreHealthy() throws Exception {
        final int energyAdjustment = crossFactorAdjustment(
                targetWithSector("Energy"),
                priceSnapshotWithReturns(2.5, 7.0),
                52,
                70,
                68,
                74,
                61,
                12
        );
        final int techAdjustment = crossFactorAdjustment(
                targetWithSector("Technology"),
                priceSnapshotWithReturns(2.5, 7.0),
                52,
                70,
                68,
                74,
                61,
                12
        );

        assertThat(energyAdjustment).isGreaterThan(techAdjustment);
    }

    @Test
    void financialNamesLosePointsWhenStabilityAndProfitabilityAreBothWeak() throws Exception {
        final int financialAdjustment = crossFactorAdjustment(
                targetWithSector("Financial Services"),
                priceSnapshotWithReturns(-4.5, -9.0),
                42,
                46,
                62,
                54,
                58,
                0
        );
        final int defensiveAdjustment = crossFactorAdjustment(
                targetWithSector("Consumer Defensive"),
                priceSnapshotWithReturns(-4.5, -9.0),
                42,
                46,
                62,
                54,
                58,
                0
        );

        assertThat(financialAdjustment).isLessThan(defensiveAdjustment);
    }

    private int crossFactorAdjustment(
            RecommendationTarget target,
            Object priceSnapshot,
            Integer priceMomentumScore,
            Integer priceStabilityScore,
            Integer fundamentalQualityScore,
            Integer profitabilityFactorScore,
            Integer valuationScore,
            int weightedSentimentScore
    ) {
        final NewsSentimentService.NewsSentimentResult news = new NewsSentimentService.NewsSentimentResult(
                0,
                "NEUTRAL",
                "",
                List.of(),
                "test",
                weightedSentimentScore,
                false,
                70,
                true,
                false
        );
        final Integer adjustment = (Integer) ReflectionTestUtils.invokeMethod(
                recommendationService,
                "resolveCrossFactorAdjustment",
                target,
                priceSnapshot,
                news,
                priceMomentumScore,
                priceStabilityScore,
                fundamentalQualityScore,
                profitabilityFactorScore,
                valuationScore,
                62
        );
        assertThat(adjustment).isNotNull();
        return adjustment;
    }

    private RecommendationTarget targetWithSector(String sector) {
        final RecommendationTarget target = new RecommendationTarget();
        target.setSector(sector);
        target.setCompanyName("테스트 종목");
        target.setTicker("TEST");
        return target;
    }

    private Object priceSnapshotWithReturns(Double changeRate7d, Double changeRate30d) throws Exception {
        final Constructor<?> constructor = priceSnapshotClass.getDeclaredConstructors()[0];
        constructor.setAccessible(true);
        final Object[] args = new Object[constructor.getParameterCount()];
        args[1] = changeRate7d;
        args[2] = changeRate30d;
        return constructor.newInstance(args);
    }
}
