package com.maemoji.backend.recommendation.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class RecommendationScoreCalculatorTest {

    private final RecommendationScoreCalculator calculator = new RecommendationScoreCalculator();

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
}
