package com.maemoji.backend.recommendation.service;

import java.util.ArrayList;
import java.util.List;

import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import org.springframework.stereotype.Component;

@Component
public class RecommendationScoreCalculator {

    public static final String FORMULA_VERSION = "SCORE_V3_PRICE_NEWS";
    public static final String FORMULA_VERSION_V4 = "SCORE_V4_MULTI_FACTOR";
    private static final int PRICE_WEIGHT = 55;
    private static final int NEWS_WEIGHT = 45;
    private final RecommendationTuningProperties tuningProperties;

    public RecommendationScoreCalculator(
            RecommendationTuningProperties tuningProperties
    ) {
        this.tuningProperties = tuningProperties;
    }

    public ScoreResult calculate(
            Double thirtyDayReturn,
            Integer newsSentimentScore,
            boolean hardStopRisk,
            boolean hardNegativeNews,
            int confidence
    ) {
        final Integer priceScore = thirtyDayReturn == null
                ? null
                : calculatePriceScore(thirtyDayReturn);
        final Integer newsScore = newsSentimentScore == null
                ? null
                : clamp((int) Math.round((newsSentimentScore + 100) / 2.0), 0, 100);

        final int appliedPriceWeight = priceScore == null ? 0 : PRICE_WEIGHT;
        final int appliedNewsWeight = newsScore == null ? 0 : NEWS_WEIGHT;
        final int totalWeight = appliedPriceWeight + appliedNewsWeight;
        final int rawScore = totalWeight == 0
                ? 50
                : (int) Math.round(
                        (priceScoreOrZero(priceScore) * appliedPriceWeight
                                + priceScoreOrZero(newsScore) * appliedNewsWeight)
                                / (double) totalWeight
                );

        int adjustedScore = rawScore;
        if (hardStopRisk) {
            adjustedScore = Math.min(adjustedScore, 30);
        } else if (hardNegativeNews) {
            adjustedScore = Math.min(adjustedScore, 45);
        }

        String status = totalWeight == 0 ? "MAINTAIN" : resolveStatus(adjustedScore);
        final boolean increaseEligible = priceScore != null
                && newsScore != null
                && confidence >= 70
                && !hardStopRisk
                && !hardNegativeNews;
        if ("INCREASE".equals(status) && !increaseEligible) {
            status = "MAINTAIN";
        }

        return new ScoreResult(
                FORMULA_VERSION,
                rawScore,
                adjustedScore,
                adjustedScore - rawScore,
                priceScore,
                newsScore,
                appliedPriceWeight,
                appliedNewsWeight,
                thirtyDayReturn,
                newsSentimentScore,
                status,
                increaseEligible
        );
    }

    public ScoreResult calculateV4Legacy(
            V4Input input,
            Double thirtyDayReturn,
            Integer newsSentimentScore
    ) {
        final V4ScoreResult v4Result = calculateV4(input);
        return toLegacyScoreResult(v4Result, thirtyDayReturn, newsSentimentScore);
    }

    public ScoreResult toLegacyScoreResult(
            V4ScoreResult v4Result,
            Double thirtyDayReturn,
            Integer newsSentimentScore
    ) {
        final Integer momentumScore = findFactorScore(v4Result, FactorCode.PRICE_MOMENTUM);
        final Integer stabilityScore = findFactorScore(v4Result, FactorCode.PRICE_STABILITY);
        final int momentumWeight = findFactorWeight(v4Result, FactorCode.PRICE_MOMENTUM);
        final int stabilityWeight = findFactorWeight(v4Result, FactorCode.PRICE_STABILITY);
        final Integer aggregatedPriceScore = aggregateScores(
                momentumScore,
                momentumWeight,
                stabilityScore,
                stabilityWeight
        );
        final int aggregatedPriceWeight = momentumWeight + stabilityWeight;
        final Integer normalizedNewsScore = findFactorScore(v4Result, FactorCode.NEWS_SENTIMENT);
        final int newsWeight = findFactorWeight(v4Result, FactorCode.NEWS_SENTIMENT);

        return new ScoreResult(
                FORMULA_VERSION_V4,
                v4Result.rawScore(),
                v4Result.finalScore(),
                v4Result.riskAdjustment(),
                aggregatedPriceScore,
                normalizedNewsScore,
                aggregatedPriceWeight,
                newsWeight,
                thirtyDayReturn,
                newsSentimentScore,
                v4Result.recommendationStatus(),
                v4Result.increaseEligible()
        );
    }

    public V4ScoreResult calculateV4(V4Input input) {
        final List<FactorResult> appliedFactors = new ArrayList<>();

        addFactorResult(
                appliedFactors,
                FactorCode.PRICE_MOMENTUM,
                input.priceMomentumScore(),
                input.priceMomentumWeight(),
                "최근 가격 흐름과 과열 여부"
        );
        addFactorResult(
                appliedFactors,
                FactorCode.PRICE_STABILITY,
                input.priceStabilityScore(),
                input.priceStabilityWeight(),
                "변동성과 하방 리스크"
        );
        addFactorResult(
                appliedFactors,
                FactorCode.NEWS_SENTIMENT,
                normalizeNewsSentiment(input.newsSentimentScore()),
                input.newsSentimentWeight(),
                "관련 뉴스 감성과 영향도"
        );
        addFactorResult(
                appliedFactors,
                FactorCode.FUNDAMENTAL_QUALITY,
                input.fundamentalQualityScore(),
                input.fundamentalQualityWeight(),
                "기업 체력과 밸류에이션"
        );
        addFactorResult(
                appliedFactors,
                FactorCode.USER_FIT,
                input.userFitScore(),
                input.userFitWeight(),
                "사용자 투자 부담과 보유 상황"
        );

        final int totalWeight = appliedFactors.stream()
                .mapToInt(FactorResult::appliedWeight)
                .sum();
        final int rawScore = totalWeight == 0
                ? 50
                : (int) Math.round(
                        appliedFactors.stream()
                                .mapToInt(factor -> factor.score() * factor.appliedWeight())
                                .sum() / (double) totalWeight
                );

        int adjustedScore = clamp(
                rawScore + input.crossFactorAdjustment() + input.userAdjustment(),
                0,
                100
        );
        if (input.hardStopRisk()) {
            adjustedScore = Math.min(adjustedScore, 30);
        } else if (input.hardNegativeNews()) {
            adjustedScore = Math.min(adjustedScore, 45);
        }

        String status = totalWeight == 0
                ? "MAINTAIN"
                : resolveV4Status(adjustedScore, input.effectiveRiskProfile());
        final boolean increaseEligible = isIncreaseEligible(input, appliedFactors);
        if ("INCREASE".equals(status) && !increaseEligible) {
            status = "MAINTAIN";
        }

        return new V4ScoreResult(
                FORMULA_VERSION_V4,
                rawScore,
                adjustedScore,
                adjustedScore - rawScore,
                input.crossFactorAdjustment(),
                input.userAdjustment(),
                input.effectiveRiskProfile(),
                status,
                increaseEligible,
                clamp(input.confidence(), 0, 100),
                appliedFactors
        );
    }

    int calculatePriceScore(double thirtyDayReturn) {
        if (thirtyDayReturn <= -35) {
            return 10;
        }
        if (thirtyDayReturn <= -20) {
            return 25;
        }
        if (thirtyDayReturn < -10) {
            return 45;
        }
        if (thirtyDayReturn <= 10) {
            return 70;
        }
        if (thirtyDayReturn <= 20) {
            return 60;
        }
        if (thirtyDayReturn <= 30) {
            return 45;
        }
        return 25;
    }

    private String resolveStatus(int score) {
        if (score >= 80) {
            return "INCREASE";
        }
        if (score >= 60) {
            return "MAINTAIN";
        }
        if (score >= 40) {
            return "REDUCE";
        }
        return "STOP";
    }

    private String resolveV4Status(int score, String effectiveRiskProfile) {
        final RecommendationTuningProperties.RiskProfileRule rule =
                tuningProperties.ruleFor(effectiveRiskProfile);
        if (score >= rule.getIncreaseThreshold()) {
            return "INCREASE";
        }
        if (score >= rule.getMaintainThreshold()) {
            return "MAINTAIN";
        }
        if (score >= rule.getReduceThreshold()) {
            return "REDUCE";
        }
        return "STOP";
    }

    private void addFactorResult(
            List<FactorResult> appliedFactors,
            FactorCode factorCode,
            Integer score,
            int weight,
            String summary
    ) {
        if (score == null || weight <= 0) {
            return;
        }
        appliedFactors.add(new FactorResult(
                factorCode,
                clamp(score, 0, 100),
                weight,
                summary
        ));
    }

    private Integer normalizeNewsSentiment(Integer newsSentimentScore) {
        if (newsSentimentScore == null) {
            return null;
        }
        if (newsSentimentScore >= -100 && newsSentimentScore <= 100) {
            return clamp((int) Math.round((newsSentimentScore + 100) / 2.0), 0, 100);
        }
        return clamp(newsSentimentScore, 0, 100);
    }

    private boolean isIncreaseEligible(V4Input input, List<FactorResult> appliedFactors) {
        if (input.hardStopRisk() || input.hardNegativeNews() || input.confidence() < 70) {
            return false;
        }

        final long strongFactorCount = appliedFactors.stream()
                .filter(factor -> factor.score() >= 65)
                .count();
        return strongFactorCount >= 2;
    }

    private Integer findFactorScore(V4ScoreResult result, FactorCode factorCode) {
        return result.factors().stream()
                .filter(factor -> factor.factorCode() == factorCode)
                .map(FactorResult::score)
                .findFirst()
                .orElse(null);
    }

    private int findFactorWeight(V4ScoreResult result, FactorCode factorCode) {
        return result.factors().stream()
                .filter(factor -> factor.factorCode() == factorCode)
                .mapToInt(FactorResult::appliedWeight)
                .findFirst()
                .orElse(0);
    }

    private Integer aggregateScores(
            Integer firstScore,
            int firstWeight,
            Integer secondScore,
            int secondWeight
    ) {
        final int totalWeight = (firstScore == null ? 0 : firstWeight)
                + (secondScore == null ? 0 : secondWeight);
        if (totalWeight == 0) {
            return null;
        }

        return (int) Math.round(
                ((firstScore == null ? 0 : firstScore * firstWeight)
                        + (secondScore == null ? 0 : secondScore * secondWeight))
                        / (double) totalWeight
        );
    }

    private int priceScoreOrZero(Integer score) {
        return score == null ? 0 : score;
    }

    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(value, max));
    }

    public record ScoreResult(
            String formulaVersion,
            int rawScore,
            int finalScore,
            int riskAdjustment,
            Integer priceScore,
            Integer newsScore,
            int priceWeight,
            int newsWeight,
            Double thirtyDayReturn,
            Integer newsSentimentScore,
            String recommendationStatus,
            boolean increaseEligible
    ) {
    }

    public record V4Input(
            Integer priceMomentumScore,
            int priceMomentumWeight,
            Integer priceStabilityScore,
            int priceStabilityWeight,
            Integer newsSentimentScore,
            int newsSentimentWeight,
            Integer fundamentalQualityScore,
            int fundamentalQualityWeight,
            Integer userFitScore,
            int userFitWeight,
            int crossFactorAdjustment,
            int userAdjustment,
            String effectiveRiskProfile,
            boolean hardStopRisk,
            boolean hardNegativeNews,
            int confidence
    ) {
        public V4Input {
            priceMomentumWeight = Math.max(priceMomentumWeight, 0);
            priceStabilityWeight = Math.max(priceStabilityWeight, 0);
            newsSentimentWeight = Math.max(newsSentimentWeight, 0);
            fundamentalQualityWeight = Math.max(fundamentalQualityWeight, 0);
            userFitWeight = Math.max(userFitWeight, 0);
        }
    }

    public enum FactorCode {
        PRICE_MOMENTUM,
        PRICE_STABILITY,
        NEWS_SENTIMENT,
        FUNDAMENTAL_QUALITY,
        USER_FIT
    }

    public record FactorResult(
            FactorCode factorCode,
            int score,
            int appliedWeight,
            String summary
    ) {
    }

    public record V4ScoreResult(
            String formulaVersion,
            int rawScore,
            int finalScore,
            int riskAdjustment,
            int crossFactorAdjustment,
            int userAdjustment,
            String effectiveRiskProfile,
            String recommendationStatus,
            boolean increaseEligible,
            int confidence,
            List<FactorResult> factors
    ) {
    }
}
