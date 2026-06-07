package com.maemoji.backend.recommendation.service;

import org.springframework.stereotype.Component;

@Component
public class RecommendationScoreCalculator {

    public static final String FORMULA_VERSION = "SCORE_V3_PRICE_NEWS";
    private static final int PRICE_WEIGHT = 55;
    private static final int NEWS_WEIGHT = 45;

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

    private int priceScoreOrZero(Integer score) {
        return score == null ? 0 : score;
    }

    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(value, max));
    }

    public record ScoreResult(
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
}
