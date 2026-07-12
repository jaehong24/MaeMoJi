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
                62,
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
                62,
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
                62,
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
                62,
                0
        );

        assertThat(financialAdjustment).isLessThan(defensiveAdjustment);
    }

    @Test
    void overheatedExpensiveTechnologyNamesReceiveExtraPenalty() throws Exception {
        final int techAdjustment = crossFactorAdjustment(
                targetWithSector("Technology"),
                priceSnapshotWithReturns(6.5, 24.0),
                36,
                58,
                78,
                76,
                50,
                60,
                8
        );
        final int utilityAdjustment = crossFactorAdjustment(
                targetWithSector("Utilities"),
                priceSnapshotWithReturns(6.5, 24.0),
                36,
                58,
                78,
                76,
                50,
                60,
                8
        );

        assertThat(techAdjustment).isLessThan(utilityAdjustment);
    }

    @Test
    void positiveNewsDoesNotOverpowerWeakGrowthAndExpensiveValuation() throws Exception {
        final int adjustment = crossFactorAdjustment(
                targetWithSector("Technology"),
                priceSnapshotWithReturns(1.2, 6.0),
                60,
                74,
                70,
                68,
                56,
                54,
                24
        );

        assertThat(adjustment).isNegative();
    }

    @Test
    void semiconductorNamesReceiveExtraPenaltyWhenOverheatedAndExpensive() throws Exception {
        final RecommendationTarget semiconductor = targetWithSector("Technology");
        semiconductor.setTicker("QCOM");
        semiconductor.setIndustry("Semiconductors");

        final RecommendationTarget genericTech = targetWithSector("Technology");
        genericTech.setTicker("TEST");
        genericTech.setIndustry("Software");

        final int semiconductorAdjustment = crossFactorAdjustment(
                semiconductor,
                priceSnapshotWithReturns(6.2, 22.0),
                48,
                72,
                80,
                82,
                50,
                72,
                16
        );
        final int genericAdjustment = crossFactorAdjustment(
                genericTech,
                priceSnapshotWithReturns(6.2, 22.0),
                48,
                72,
                80,
                82,
                50,
                72,
                16
        );

        assertThat(semiconductorAdjustment).isLessThan(genericAdjustment);
    }

    @Test
    void megaPlatformPullbackGetsLessPenaltyThanGenericTechnologyWhenQualityRemainsStrong() throws Exception {
        final RecommendationTarget megaPlatform = targetWithSector("Communication Services");
        megaPlatform.setTicker("META");
        megaPlatform.setIndustry("Internet Content & Information");

        final RecommendationTarget genericTechnology = targetWithSector("Technology");
        genericTechnology.setTicker("TEST");
        genericTechnology.setIndustry("Hardware");

        final int megaPlatformAdjustment = crossFactorAdjustment(
                megaPlatform,
                priceSnapshotWithReturns(-3.2, -11.0),
                40,
                46,
                83,
                86,
                79,
                82,
                10
        );
        final int genericAdjustment = crossFactorAdjustment(
                genericTechnology,
                priceSnapshotWithReturns(-3.2, -11.0),
                40,
                46,
                83,
                86,
                79,
                82,
                10
        );

        assertThat(megaPlatformAdjustment).isGreaterThan(genericAdjustment);
    }

    @Test
    void highBetaSoftwareKeepsExtraPenaltyWhenValuationAndStabilityAreWeak() throws Exception {
        final RecommendationTarget highBetaSoftware = targetWithSector("Technology");
        highBetaSoftware.setTicker("SHOP");
        highBetaSoftware.setIndustry("Software - Application");

        final RecommendationTarget genericIndustrial = targetWithSector("Industrials");
        genericIndustrial.setTicker("TEST");
        genericIndustrial.setIndustry("Industrial Distribution");

        final int softwareAdjustment = crossFactorAdjustment(
                highBetaSoftware,
                priceSnapshotWithReturns(1.6, 12.0),
                58,
                52,
                68,
                70,
                52,
                66,
                8
        );
        final int genericAdjustment = crossFactorAdjustment(
                genericIndustrial,
                priceSnapshotWithReturns(1.6, 12.0),
                58,
                52,
                68,
                70,
                52,
                66,
                8
        );

        assertThat(softwareAdjustment).isLessThan(genericAdjustment);
    }

    @Test
    void unknownSoftwareTickerStillReceivesHighBetaGrowthPenaltyByIndustry() throws Exception {
        final RecommendationTarget unknownSoftware = targetWithSector("Technology");
        unknownSoftware.setTicker("ABCD");
        unknownSoftware.setIndustry("Cloud Software");

        final RecommendationTarget genericIndustrial = targetWithSector("Industrials");
        genericIndustrial.setTicker("EFGH");
        genericIndustrial.setIndustry("Industrial Distribution");

        final int unknownSoftwareAdjustment = crossFactorAdjustment(
                unknownSoftware,
                priceSnapshotWithReturns(1.8, 11.0),
                57,
                54,
                67,
                69,
                54,
                65,
                6
        );
        final int genericIndustrialAdjustment = crossFactorAdjustment(
                genericIndustrial,
                priceSnapshotWithReturns(1.8, 11.0),
                57,
                54,
                67,
                69,
                54,
                65,
                6
        );

        assertThat(unknownSoftwareAdjustment).isLessThan(genericIndustrialAdjustment);
    }

    @Test
    void unknownMegaPlatformTickerStillGetsPullbackSupportByIndustry() throws Exception {
        final RecommendationTarget unknownPlatform = targetWithSector("Communication Services");
        unknownPlatform.setTicker("WXYZ");
        unknownPlatform.setIndustry("Interactive Media & Services");

        final RecommendationTarget genericTech = targetWithSector("Technology");
        genericTech.setTicker("QRST");
        genericTech.setIndustry("Computer Hardware");

        final int unknownPlatformAdjustment = crossFactorAdjustment(
                unknownPlatform,
                priceSnapshotWithReturns(-3.0, -10.5),
                40,
                46,
                84,
                85,
                78,
                82,
                10
        );
        final int genericTechAdjustment = crossFactorAdjustment(
                genericTech,
                priceSnapshotWithReturns(-3.0, -10.5),
                40,
                46,
                84,
                85,
                78,
                82,
                10
        );

        assertThat(unknownPlatformAdjustment).isGreaterThan(genericTechAdjustment);
    }

    private int crossFactorAdjustment(
            RecommendationTarget target,
            Object priceSnapshot,
            Integer priceMomentumScore,
            Integer priceStabilityScore,
            Integer fundamentalQualityScore,
            Integer profitabilityFactorScore,
            Integer valuationScore,
            Integer qualityOfGrowthScore,
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
                "NONE",
                70,
                false,
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
                qualityOfGrowthScore
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
