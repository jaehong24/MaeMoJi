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

        // V4의 최종 판단 축은 가격, 뉴스, 밸류에이션, 성장의 질, 사용자 적합도를 기본으로 보되,
        // 기업 체력은 수익성/안정성/현금흐름이 묶인 fundamental score에 담아 함께 반영한다.
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
                "기업 체력"
        );
        addFactorResult(
                appliedFactors,
                FactorCode.VALUATION,
                input.valuationScore(),
                input.valuationWeight(),
                "현재 밸류에이션 부담"
        );
        addFactorResult(
                appliedFactors,
                FactorCode.QUALITY_OF_GROWTH,
                input.qualityOfGrowthScore(),
                input.qualityOfGrowthWeight(),
                "성장의 질과 지속 가능성"
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

        final int conflictAdjustment = resolveConflictAdjustment(input);
        int adjustedScore = clamp(
                rawScore + input.crossFactorAdjustment() + conflictAdjustment + input.userAdjustment(),
                0,
                100
        );
        if (input.hardStopRisk()) {
            adjustedScore = Math.min(adjustedScore, 30);
        } else if (input.hardNegativeNews()) {
            adjustedScore = Math.min(adjustedScore, resolveHardNegativeNewsCap(input));
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
                input.crossFactorAdjustment() + conflictAdjustment,
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
        final RecommendationTuningProperties.RiskProfileRule rule =
                tuningProperties.ruleFor(input.effectiveRiskProfile());
        final RecommendationTuningProperties.IncreaseGuard guard =
                tuningProperties.getIncreaseGuard();
        if (input.hardStopRisk()
                || input.hardNegativeNews()
                || input.confidence() < rule.getMinConfidenceForIncrease()) {
            return false;
        }
        if (input.priceMomentumScore() == null || input.priceStabilityScore() == null) {
            return false;
        }
        if (input.fundamentalQualityScore() == null && input.qualityOfGrowthScore() == null) {
            return false;
        }
        if (input.valuationScore() != null
                && input.valuationScore() <= guard.getAbsoluteValuationBlockMax()) {
            return false;
        }
        if (input.valuationScore() != null
                && input.valuationScore() <= guard.getExpensiveQualityValuationMax()
                && input.fundamentalQualityScore() != null
                && input.fundamentalQualityScore() >= guard.getExpensiveQualityFundamentalMin()
                && input.qualityOfGrowthScore() != null
                && input.qualityOfGrowthScore() >= guard.getExpensiveQualityGrowthMin()
                && input.priceMomentumScore() != null
                && input.priceMomentumScore() <= guard.getExpensiveQualityMomentumMax()) {
            return false;
        }

        final long strongFactorCount = appliedFactors.stream()
                .filter(factor -> factor.score() >= rule.getStrongFactorScoreThreshold())
                .count();
        return strongFactorCount >= rule.getMinStrongFactorCount();
    }

    private int resolveConflictAdjustment(V4Input input) {
        final RecommendationTuningProperties.ConflictRules rule =
                tuningProperties.getConflictRules();
        int adjustment = 0;

        final Integer fundamental = input.fundamentalQualityScore();
        final Integer valuation = input.valuationScore();
        final Integer qualityOfGrowth = input.qualityOfGrowthScore();
        final Integer momentum = input.priceMomentumScore();
        final Integer stability = input.priceStabilityScore();

        if (fundamental != null
                && fundamental >= rule.getCompounderFundamentalMin()
                && qualityOfGrowth != null
                && qualityOfGrowth >= rule.getCompounderGrowthMin()
                && valuation != null
                && valuation >= rule.getCompounderValuationMin()
                && stability != null
                && stability >= rule.getCompounderStabilityMin()
                && momentum != null
                && momentum >= rule.getCompounderMomentumMin()) {
            adjustment += rule.getCompounderBonus();
        }
        if (fundamental != null
                && fundamental >= rule.getExpensiveEliteFundamentalMin()
                && qualityOfGrowth != null
                && qualityOfGrowth >= rule.getExpensiveEliteGrowthMin()
                && valuation != null
                && valuation <= rule.getExpensiveEliteValuationMax()) {
            adjustment += rule.getExpensiveElitePenalty();
        }
        if (fundamental != null
                && fundamental >= rule.getExpensiveGoodFundamentalMin()
                && qualityOfGrowth != null
                && qualityOfGrowth >= rule.getExpensiveGoodGrowthMin()
                && valuation != null
                && valuation <= rule.getExpensiveGoodValuationMax()
                && ((momentum != null && momentum <= rule.getExpensiveGoodMomentumMax())
                || (stability != null && stability <= rule.getExpensiveGoodStabilityMax()))) {
                adjustment += rule.getExpensiveGoodPenalty();
                if (momentum != null
                        && momentum <= rule.getExpensiveGoodMomentumMax()
                        && stability != null
                        && stability <= rule.getExpensiveGoodStabilityMax()) {
                    adjustment -= 2;
                }
        }
        if (fundamental != null
                && fundamental >= 82
                && qualityOfGrowth != null
                && qualityOfGrowth >= 88
                && valuation != null
                && valuation <= 40
                && stability != null
                && stability >= 84
                && momentum != null
                && momentum >= 58) {
            adjustment += 2;
        }
        if (fundamental != null
                && fundamental >= 80
                && qualityOfGrowth != null
                && qualityOfGrowth >= 78
                && valuation != null
                && valuation >= 76
                && momentum != null
                && momentum >= 36
                && momentum <= 48
                && stability != null
                && stability >= 42
                && stability <= 58) {
            adjustment += 3;
        }
        if (valuation != null
                && valuation >= rule.getWeakGrowthValuationMin()
                && qualityOfGrowth != null
                && qualityOfGrowth <= rule.getWeakGrowthQualityMax()) {
            adjustment += rule.getWeakGrowthPenalty();
        }
        if (valuation != null
                && valuation >= rule.getWeakGrowthValueTrapValuationMin()
                && qualityOfGrowth != null
                && qualityOfGrowth <= rule.getWeakGrowthValueTrapQualityMax()
                && fundamental != null
                && fundamental <= rule.getWeakGrowthValueTrapFundamentalMax()) {
            adjustment += rule.getWeakGrowthValueTrapPenalty();
        }
        if (fundamental != null
                && fundamental >= rule.getOverheatStrongCompanyFundamentalMin()
                && qualityOfGrowth != null
                && qualityOfGrowth >= rule.getOverheatStrongCompanyGrowthMin()
                && momentum != null
                && momentum <= rule.getOverheatStrongCompanyMomentumMax()) {
            adjustment += rule.getOverheatStrongCompanyPenalty();
        }
        if (fundamental != null
                && fundamental >= 78
                && qualityOfGrowth != null
                && qualityOfGrowth >= 70
                && valuation != null
                && valuation <= 54
                && momentum != null
                && momentum <= 54
                && stability != null
                && stability <= 58) {
            adjustment -= 4;
        }
        final Integer normalizedNews = normalizeNewsSentiment(input.newsSentimentScore());
        if (normalizedNews != null
                && normalizedNews >= rule.getPositiveNewsExpensiveNewsMin()
                && valuation != null
                && valuation <= rule.getPositiveNewsExpensiveValuationMax()) {
            adjustment += rule.getPositiveNewsExpensivePenalty();
            if ((momentum != null && momentum <= rule.getExpensiveGoodMomentumMax())
                    || (stability != null && stability <= rule.getExpensiveGoodStabilityMax())) {
                adjustment -= 2;
            }
        }
        if (qualityOfGrowth != null
                && qualityOfGrowth <= rule.getSlowingGrowthExpensiveQualityMax()
                && valuation != null
                && valuation <= rule.getSlowingGrowthExpensiveValuationMax()) {
            adjustment += rule.getSlowingGrowthExpensivePenalty();
            if (momentum != null && momentum <= rule.getExpensiveGoodMomentumMax()) {
                adjustment -= 2;
            }
        }
        if (qualityOfGrowth != null
                && qualityOfGrowth <= 58
                && valuation != null
                && valuation <= 56
                && momentum != null
                && momentum <= 52
                && stability != null
                && stability <= 54) {
            adjustment -= 4;
        }
        if (fundamental != null
                && fundamental >= 82
                && qualityOfGrowth != null
                && qualityOfGrowth >= 88
                && valuation != null
                && valuation >= 32
                && valuation <= 45
                && stability != null
                && stability >= 44
                && momentum != null
                && momentum >= 40) {
            adjustment += 3;
        }
        if (valuation != null
                && valuation <= 58
                && qualityOfGrowth != null
                && qualityOfGrowth >= 60
                && qualityOfGrowth <= 72
                && stability != null
                && stability <= 58
                && momentum != null
                && momentum <= 58) {
            adjustment -= 3;
        }
        if (momentum != null
                && momentum <= 42
                && stability != null
                && stability <= 50
                && fundamental != null
                && fundamental >= 78
                && qualityOfGrowth != null
                && qualityOfGrowth >= 76
                && valuation != null
                && valuation >= 74) {
            adjustment += 2;
        }

        return adjustment;
    }

    private int resolveHardNegativeNewsCap(V4Input input) {
        final RecommendationTuningProperties.NegativeNews rule =
                tuningProperties.getNegativeNews();
        int cap = rule.getMaxCap();

        final Integer normalizedNews = normalizeNewsSentiment(input.newsSentimentScore());
        final Integer fundamental = input.fundamentalQualityScore();
        final Integer stability = input.priceStabilityScore();
        final Integer qualityOfGrowth = input.qualityOfGrowthScore();
        final Integer momentum = input.priceMomentumScore();
        final Integer valuation = input.valuationScore();

        if (normalizedNews != null) {
            if (normalizedNews <= 10) {
                cap += rule.getNormalizedNews10Penalty();
            } else if (normalizedNews <= 20) {
                cap += rule.getNormalizedNews20Penalty();
            } else if (normalizedNews <= 30) {
                cap += rule.getNormalizedNews30Penalty();
            }
        }

        if (fundamental != null && fundamental >= 82) {
            cap += rule.getStrongFundamentalBonus();
        } else if (fundamental != null && fundamental <= 58) {
            cap += rule.getWeakFundamentalPenalty();
        }

        if (stability != null && stability >= 80) {
            cap += rule.getStrongStabilityBonus();
        } else if (stability != null && stability <= 40) {
            cap += rule.getWeakStabilityPenalty();
        }

        if (qualityOfGrowth != null && qualityOfGrowth >= 80) {
            cap += rule.getStrongGrowthQualityBonus();
        } else if (qualityOfGrowth != null && qualityOfGrowth <= 45) {
            cap += rule.getWeakGrowthQualityPenalty();
        }

        if (momentum != null && momentum <= 30) {
            cap += rule.getWeakMomentumPenalty();
        }

        if (valuation != null && valuation <= 30) {
            cap += rule.getVeryLowValuationPenalty();
        }

        cap += switch (input.hardNegativeNewsCategory()) {
            case "ACCOUNTING_OR_FRAUD" -> rule.getAccountingOrFraudPenalty();
            case "LIQUIDITY_OR_BANKRUPTCY" -> rule.getLiquidityOrBankruptcyPenalty();
            case "REGULATORY_INVESTIGATION" -> rule.getRegulatoryInvestigationPenalty();
            case "LAWSUIT_OR_RECALL" -> rule.getLawsuitOrRecallPenalty();
            case "GUIDANCE_OR_EARNINGS" -> rule.getGuidanceOrEarningsPenalty();
            case "DEMAND_OR_MARGIN" -> rule.getDemandOrMarginPenalty();
            default -> 0;
        };

        return clamp(cap, rule.getMinCap(), rule.getMaxCap());
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
            Integer valuationScore,
            int valuationWeight,
            Integer qualityOfGrowthScore,
            int qualityOfGrowthWeight,
            Integer userFitScore,
            int userFitWeight,
            int crossFactorAdjustment,
            int userAdjustment,
            String effectiveRiskProfile,
            boolean hardStopRisk,
            boolean hardNegativeNews,
            String hardNegativeNewsCategory,
            int confidence
    ) {
        public V4Input {
            priceMomentumWeight = Math.max(priceMomentumWeight, 0);
            priceStabilityWeight = Math.max(priceStabilityWeight, 0);
            newsSentimentWeight = Math.max(newsSentimentWeight, 0);
            fundamentalQualityWeight = Math.max(fundamentalQualityWeight, 0);
            valuationWeight = Math.max(valuationWeight, 0);
            qualityOfGrowthWeight = Math.max(qualityOfGrowthWeight, 0);
            userFitWeight = Math.max(userFitWeight, 0);
            hardNegativeNewsCategory = hardNegativeNewsCategory == null
                    ? "NONE"
                    : hardNegativeNewsCategory.trim().toUpperCase();
        }

        public V4Input(
                Integer priceMomentumScore,
                int priceMomentumWeight,
                Integer priceStabilityScore,
                int priceStabilityWeight,
                Integer newsSentimentScore,
                int newsSentimentWeight,
                Integer fundamentalQualityScore,
                int fundamentalQualityWeight,
                Integer valuationScore,
                int valuationWeight,
                Integer qualityOfGrowthScore,
                int qualityOfGrowthWeight,
                Integer userFitScore,
                int userFitWeight,
                int crossFactorAdjustment,
                int userAdjustment,
                String effectiveRiskProfile,
                boolean hardStopRisk,
                boolean hardNegativeNews,
                int confidence
        ) {
            this(
                    priceMomentumScore,
                    priceMomentumWeight,
                    priceStabilityScore,
                    priceStabilityWeight,
                    newsSentimentScore,
                    newsSentimentWeight,
                    fundamentalQualityScore,
                    fundamentalQualityWeight,
                    valuationScore,
                    valuationWeight,
                    qualityOfGrowthScore,
                    qualityOfGrowthWeight,
                    userFitScore,
                    userFitWeight,
                    crossFactorAdjustment,
                    userAdjustment,
                    effectiveRiskProfile,
                    hardStopRisk,
                    hardNegativeNews,
                    "NONE",
                    confidence
            );
        }
    }

    public enum FactorCode {
        PRICE_MOMENTUM,
        PRICE_STABILITY,
        NEWS_SENTIMENT,
        FUNDAMENTAL_QUALITY,
        VALUATION,
        QUALITY_OF_GROWTH,
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
