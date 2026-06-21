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
                        62,
                        10,
                        68,
                        10,
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
        assertThat(result.factors()).hasSize(7);
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
                        64,
                        10,
                        70,
                        10,
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
                        55,
                        10,
                        63,
                        10,
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
    void v4HardNegativeNewsCapsStatusToReduceRange() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        82,
                        20,
                        84,
                        12,
                        -70,
                        22,
                        86,
                        14,
                        74,
                        12,
                        88,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        true,
                        90
                )
        );

        assertThat(result.finalScore()).isBetween(40, 45);
        assertThat(result.recommendationStatus()).isEqualTo("REDUCE");
        assertThat(result.increaseEligible()).isFalse();
    }

    @Test
    void v4HardNegativeNewsPushesFragileNamesToStopMoreAggressively() {
        final RecommendationScoreCalculator.V4ScoreResult resilient = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        68,
                        20,
                        84,
                        12,
                        -70,
                        22,
                        86,
                        14,
                        72,
                        12,
                        84,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        true,
                        86
                )
        );
        final RecommendationScoreCalculator.V4ScoreResult fragile = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        12,
                        20,
                        24,
                        12,
                        -70,
                        22,
                        54,
                        14,
                        22,
                        12,
                        40,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        true,
                        86
                )
        );

        assertThat(resilient.recommendationStatus()).isEqualTo("REDUCE");
        assertThat(resilient.finalScore()).isGreaterThanOrEqualTo(40);
        assertThat(fragile.recommendationStatus()).isEqualTo("STOP");
        assertThat(fragile.finalScore()).isLessThan(resilient.finalScore());
    }

    @Test
    void v4AccountingFraudIsPenalizedMoreThanGuidanceCut() {
        final RecommendationScoreCalculator.V4ScoreResult guidance = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        72, 20,
                        82, 12,
                        -70, 22,
                        84, 14,
                        70, 12,
                        82, 12,
                        60, 8,
                        0, 0,
                        "BALANCED",
                        false,
                        true,
                        "GUIDANCE_OR_EARNINGS",
                        86
                )
        );
        final RecommendationScoreCalculator.V4ScoreResult accounting = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        72, 20,
                        82, 12,
                        -70, 22,
                        84, 14,
                        70, 12,
                        82, 12,
                        60, 8,
                        0, 0,
                        "BALANCED",
                        false,
                        true,
                        "ACCOUNTING_OR_FRAUD",
                        86
                )
        );

        assertThat(guidance.recommendationStatus()).isEqualTo("REDUCE");
        assertThat(accounting.recommendationStatus()).isEqualTo("REDUCE");
        assertThat(accounting.finalScore()).isLessThan(guidance.finalScore());
    }

    @Test
    void v4HardNegativePenaltyUsesTuningProperties() {
        final RecommendationTuningProperties customProperties =
                new RecommendationTuningProperties();
        customProperties.getNegativeNews().setAccountingOrFraudPenalty(-12);
        customProperties.getNegativeNews().setGuidanceOrEarningsPenalty(0);
        final RecommendationScoreCalculator customCalculator =
                new RecommendationScoreCalculator(customProperties);

        final RecommendationScoreCalculator.V4ScoreResult guidance = customCalculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        72, 20,
                        82, 12,
                        -70, 22,
                        84, 14,
                        70, 12,
                        82, 12,
                        60, 8,
                        0, 0,
                        "BALANCED",
                        false,
                        true,
                        "GUIDANCE_OR_EARNINGS",
                        86
                )
        );
        final RecommendationScoreCalculator.V4ScoreResult accounting = customCalculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        72, 20,
                        82, 12,
                        -70, 22,
                        84, 14,
                        70, 12,
                        82, 12,
                        60, 8,
                        0, 0,
                        "BALANCED",
                        false,
                        true,
                        "ACCOUNTING_OR_FRAUD",
                        86
                )
        );

        assertThat(accounting.finalScore()).isLessThan(guidance.finalScore());
        assertThat(guidance.finalScore()).isEqualTo(45);
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
                        62,
                        10,
                        68,
                        10,
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
                        62,
                        10,
                        68,
                        10,
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
                        58,
                        10,
                        66,
                        10,
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

    @Test
    void v4IncreaseEligibilityUsesRiskProfileSpecificConfidenceAndFactorRules() {
        final RecommendationScoreCalculator.V4ScoreResult balanced = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        76,
                        20,
                        70,
                        12,
                        72,
                        22,
                        74,
                        14,
                        66,
                        12,
                        72,
                        12,
                        64,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        70
                )
        );
        final RecommendationScoreCalculator.V4ScoreResult aggressive = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        76,
                        20,
                        70,
                        12,
                        72,
                        22,
                        74,
                        14,
                        66,
                        12,
                        72,
                        12,
                        64,
                        8,
                        0,
                        0,
                        "AGGRESSIVE",
                        false,
                        false,
                        70
                )
        );

        assertThat(balanced.increaseEligible()).isFalse();
        assertThat(aggressive.increaseEligible()).isTrue();
    }

    @Test
    void v4BlocksIncreaseForHighQualityButExpensiveNames() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        62,
                        20,
                        87,
                        12,
                        null,
                        0,
                        84,
                        14,
                        37,
                        12,
                        91,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        88
                )
        );

        assertThat(result.increaseEligible()).isFalse();
        assertThat(result.crossFactorAdjustment()).isNegative();
        assertThat(result.recommendationStatus()).isEqualTo("MAINTAIN");
    }

    @Test
    void v4IncreaseGuardUsesTuningProperties() {
        final RecommendationTuningProperties customProperties =
                new RecommendationTuningProperties();
        customProperties.getIncreaseGuard().setAbsoluteValuationBlockMax(30);
        customProperties.getIncreaseGuard().setExpensiveQualityValuationMax(40);
        customProperties.getIncreaseGuard().setExpensiveQualityFundamentalMin(85);
        customProperties.getIncreaseGuard().setExpensiveQualityGrowthMin(85);
        customProperties.getIncreaseGuard().setExpensiveQualityMomentumMax(50);
        final RecommendationScoreCalculator customCalculator =
                new RecommendationScoreCalculator(customProperties);

        final RecommendationScoreCalculator.V4ScoreResult result = customCalculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        62,
                        20,
                        87,
                        12,
                        72,
                        22,
                        84,
                        14,
                        37,
                        12,
                        91,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        88
                )
        );

        assertThat(result.increaseEligible()).isTrue();
    }

    @Test
    void v4PenalizesCheapLookingButLowGrowthQualityNames() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        64,
                        20,
                        60,
                        12,
                        null,
                        0,
                        61,
                        14,
                        78,
                        12,
                        52,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        82
                )
        );

        assertThat(result.crossFactorAdjustment()).isNegative();
        assertThat(result.finalScore()).isLessThan(result.rawScore());
        assertThat(result.recommendationStatus()).isEqualTo("REDUCE");
    }

    @Test
    void v4ConflictRulesUseTuningProperties() {
        final RecommendationTuningProperties customProperties =
                new RecommendationTuningProperties();
        customProperties.getConflictRules().setWeakGrowthPenalty(-10);
        customProperties.getConflictRules().setWeakGrowthValueTrapPenalty(-7);
        final RecommendationScoreCalculator customCalculator =
                new RecommendationScoreCalculator(customProperties);

        final RecommendationScoreCalculator.V4ScoreResult defaultResult = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        64,
                        20,
                        60,
                        12,
                        null,
                        0,
                        61,
                        14,
                        78,
                        12,
                        52,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        82
                )
        );
        final RecommendationScoreCalculator.V4ScoreResult customResult = customCalculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        64,
                        20,
                        60,
                        12,
                        null,
                        0,
                        61,
                        14,
                        78,
                        12,
                        52,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        82
                )
        );

        assertThat(customResult.crossFactorAdjustment())
                .isLessThan(defaultResult.crossFactorAdjustment());
        assertThat(customResult.finalScore()).isLessThan(defaultResult.finalScore());
    }

    @Test
    void v4CompounderBonusLiftsHighQualityMegaCaps() {
        final RecommendationScoreCalculator.V4ScoreResult result = calculator.calculateV4(
                new RecommendationScoreCalculator.V4Input(
                        62,
                        20,
                        87,
                        12,
                        null,
                        0,
                        80,
                        14,
                        73,
                        12,
                        70,
                        12,
                        60,
                        8,
                        0,
                        0,
                        "BALANCED",
                        false,
                        false,
                        78
                )
        );

        assertThat(result.crossFactorAdjustment()).isPositive();
        assertThat(result.finalScore()).isGreaterThan(result.rawScore());
        assertThat(result.recommendationStatus()).isEqualTo("INCREASE");
    }
}
