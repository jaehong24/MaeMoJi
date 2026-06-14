package com.maemoji.backend.recommendation.service;

import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class RecommendationScoreCalculatorTest {

    private final RecommendationScoreCalculator calculator =
            new RecommendationScoreCalculator(new RecommendationTuningProperties());

    @Test
    void calculatesWeightedScoreFromPriceAndNews() {
        final RecommendationScoreCalculator.ScoreResult result =
                calculator.calculate(5.0, 40, false, false, 80);

        assertThat(result.priceScore()).isEqualTo(70);
        assertThat(result.newsScore()).isEqualTo(70);
        assertThat(result.finalScore()).isEqualTo(70);
        assertThat(result.recommendationStatus()).isEqualTo("MAINTAIN");
    }

    @Test
    void excludesMissingPriceFromWeightCalculation() {
        final RecommendationScoreCalculator.ScoreResult result =
                calculator.calculate(null, 60, false, false, 80);

        assertThat(result.priceWeight()).isZero();
        assertThat(result.newsWeight()).isEqualTo(45);
        assertThat(result.finalScore()).isEqualTo(80);
        assertThat(result.recommendationStatus()).isEqualTo("MAINTAIN");
        assertThat(result.increaseEligible()).isFalse();
    }

    @Test
    void hardNegativeNewsCapsScoreAtReduceRange() {
        final RecommendationScoreCalculator.ScoreResult result =
                calculator.calculate(5.0, 80, false, true, 90);

        assertThat(result.finalScore()).isEqualTo(45);
        assertThat(result.riskAdjustment()).isNegative();
        assertThat(result.recommendationStatus()).isEqualTo("REDUCE");
    }

    @Test
    void severeRiskForcesStop() {
        final RecommendationScoreCalculator.ScoreResult result =
                calculator.calculate(-40.0, 80, true, false, 90);

        assertThat(result.finalScore()).isLessThanOrEqualTo(30);
        assertThat(result.recommendationStatus()).isEqualTo("STOP");
    }

    @Test
    void maintainsWhenNoScoringDataIsAvailable() {
        final RecommendationScoreCalculator.ScoreResult result =
                calculator.calculate(null, null, false, false, 55);

        assertThat(result.finalScore()).isEqualTo(50);
        assertThat(result.recommendationStatus()).isEqualTo("MAINTAIN");
        assertThat(result.priceWeight()).isZero();
        assertThat(result.newsWeight()).isZero();
    }

    @Test
    void calculatesV4ScoreFromMultipleFactors() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        72,
                        25,
                        58,
                        15,
                        28,
                        25,
                        70,
                        20,
                        54,
                        15,
                        -3,
                        2,
                        "BALANCED",
                        false,
                        false,
                        82
                )
        );

        assertThat(result.formulaVersion()).isEqualTo(RecommendationScoreCalculator.FORMULA_VERSION_V4);
        assertThat(result.rawScore()).isBetween(0, 100);
        assertThat(result.finalScore()).isBetween(0, 100);
        assertThat(result.factors()).hasSize(5);
        assertThat(result.recommendationStatus()).isEqualTo("MAINTAIN");
    }

    @Test
    void v4BlocksIncreaseWhenConfidenceIsLow() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        90,
                        25,
                        80,
                        15,
                        85,
                        25,
                        75,
                        20,
                        70,
                        15,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        60
                )
        );

        assertThat(result.rawScore()).isGreaterThanOrEqualTo(80);
        assertThat(result.increaseEligible()).isFalse();
        assertThat(result.recommendationStatus()).isEqualTo("MAINTAIN");
    }

    @Test
    void v4HardRiskStillCapsToStopRange() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        85,
                        25,
                        75,
                        15,
                        80,
                        25,
                        70,
                        20,
                        60,
                        15,
                        0,
                        0,
                        "BALANCED",
                        true,
                        false,
                        90
                )
        );

        assertThat(result.finalScore()).isLessThanOrEqualTo(30);
        assertThat(result.recommendationStatus()).isEqualTo("STOP");
    }

    @Test
    void v4SameScoreChangesStatusByRiskProfile() {
        final RecommendationScoreCalculator.V4ScoreResult safeFirst = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        72,
                        25,
                        58,
                        15,
                        28,
                        25,
                        70,
                        20,
                        54,
                        15,
                        0,
                        0,
                        "SAFE_FIRST",
                        false,
                        false,
                        82
                )
        );
        final RecommendationScoreCalculator.V4ScoreResult growthSeeker = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        72,
                        25,
                        58,
                        15,
                        28,
                        25,
                        70,
                        20,
                        54,
                        15,
                        0,
                        0,
                        "GROWTH_SEEKER",
                        false,
                        false,
                        82
                )
        );

        assertThat(safeFirst.finalScore()).isEqualTo(growthSeeker.finalScore());
        assertThat(safeFirst.recommendationStatus()).isEqualTo("REDUCE");
        assertThat(growthSeeker.recommendationStatus()).isEqualTo("MAINTAIN");
    }

    @Test
    void v4CarriesAppliedRiskProfile() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        80,
                        25,
                        70,
                        15,
                        45,
                        25,
                        72,
                        20,
                        60,
                        15,
                        0,
                        5,
                        "AGGRESSIVE",
                        false,
                        false,
                        85
                )
        );

        assertThat(result.effectiveRiskProfile()).isEqualTo("AGGRESSIVE");
        assertThat(result.userAdjustment()).isEqualTo(5);
    }
}
