package com.maemoji.backend.recommendation.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "maemoji.recommendation.v4")
public class RecommendationTuningProperties {

    private FactorWeights factorWeights = new FactorWeights();
    private RiskProfiles riskProfiles = new RiskProfiles();
    private PriceStability priceStability = new PriceStability();
    private Fundamental fundamental = new Fundamental();

    public FactorWeights getFactorWeights() {
        return factorWeights;
    }

    public void setFactorWeights(FactorWeights factorWeights) {
        this.factorWeights = factorWeights;
    }

    public RiskProfiles getRiskProfiles() {
        return riskProfiles;
    }

    public void setRiskProfiles(RiskProfiles riskProfiles) {
        this.riskProfiles = riskProfiles;
    }

    public PriceStability getPriceStability() {
        return priceStability;
    }

    public void setPriceStability(PriceStability priceStability) {
        this.priceStability = priceStability;
    }

    public Fundamental getFundamental() {
        return fundamental;
    }

    public void setFundamental(Fundamental fundamental) {
        this.fundamental = fundamental;
    }

    public RiskProfileRule ruleFor(String effectiveRiskProfile) {
        final String key = effectiveRiskProfile == null
                ? "BALANCED"
                : effectiveRiskProfile.trim().toUpperCase();
        return switch (key) {
            case "SAFE_FIRST" -> riskProfiles.safeFirst;
            case "GROWTH_SEEKER" -> riskProfiles.growthSeeker;
            case "AGGRESSIVE" -> riskProfiles.aggressive;
            default -> riskProfiles.balanced;
        };
    }

    public static class FactorWeights {
        private int priceMomentum = 25;
        private int priceStability = 15;
        private int newsSentiment = 25;
        private int fundamentalQuality = 20;
        private int userFit = 15;

        public int getPriceMomentum() {
            return priceMomentum;
        }

        public void setPriceMomentum(int priceMomentum) {
            this.priceMomentum = priceMomentum;
        }

        public int getPriceStability() {
            return priceStability;
        }

        public void setPriceStability(int priceStability) {
            this.priceStability = priceStability;
        }

        public int getNewsSentiment() {
            return newsSentiment;
        }

        public void setNewsSentiment(int newsSentiment) {
            this.newsSentiment = newsSentiment;
        }

        public int getFundamentalQuality() {
            return fundamentalQuality;
        }

        public void setFundamentalQuality(int fundamentalQuality) {
            this.fundamentalQuality = fundamentalQuality;
        }

        public int getUserFit() {
            return userFit;
        }

        public void setUserFit(int userFit) {
            this.userFit = userFit;
        }
    }

    public static class RiskProfiles {
        private RiskProfileRule safeFirst = new RiskProfileRule(90, 68, 42, -5);
        private RiskProfileRule balanced = new RiskProfileRule(85, 60, 35, 0);
        private RiskProfileRule growthSeeker = new RiskProfileRule(82, 56, 32, 2);
        private RiskProfileRule aggressive = new RiskProfileRule(78, 52, 28, 5);

        public RiskProfileRule getSafeFirst() {
            return safeFirst;
        }

        public void setSafeFirst(RiskProfileRule safeFirst) {
            this.safeFirst = safeFirst;
        }

        public RiskProfileRule getBalanced() {
            return balanced;
        }

        public void setBalanced(RiskProfileRule balanced) {
            this.balanced = balanced;
        }

        public RiskProfileRule getGrowthSeeker() {
            return growthSeeker;
        }

        public void setGrowthSeeker(RiskProfileRule growthSeeker) {
            this.growthSeeker = growthSeeker;
        }

        public RiskProfileRule getAggressive() {
            return aggressive;
        }

        public void setAggressive(RiskProfileRule aggressive) {
            this.aggressive = aggressive;
        }
    }

    public static class RiskProfileRule {
        private int increaseThreshold;
        private int maintainThreshold;
        private int reduceThreshold;
        private int userAdjustment;

        public RiskProfileRule() {
        }

        public RiskProfileRule(
                int increaseThreshold,
                int maintainThreshold,
                int reduceThreshold,
                int userAdjustment
        ) {
            this.increaseThreshold = increaseThreshold;
            this.maintainThreshold = maintainThreshold;
            this.reduceThreshold = reduceThreshold;
            this.userAdjustment = userAdjustment;
        }

        public int getIncreaseThreshold() {
            return increaseThreshold;
        }

        public void setIncreaseThreshold(int increaseThreshold) {
            this.increaseThreshold = increaseThreshold;
        }

        public int getMaintainThreshold() {
            return maintainThreshold;
        }

        public void setMaintainThreshold(int maintainThreshold) {
            this.maintainThreshold = maintainThreshold;
        }

        public int getReduceThreshold() {
            return reduceThreshold;
        }

        public void setReduceThreshold(int reduceThreshold) {
            this.reduceThreshold = reduceThreshold;
        }

        public int getUserAdjustment() {
            return userAdjustment;
        }

        public void setUserAdjustment(int userAdjustment) {
            this.userAdjustment = userAdjustment;
        }
    }

    public static class PriceStability {
        private int stress5Score = 85;
        private int stress10Score = 75;
        private int stress20Score = 60;
        private int stress30Score = 40;
        private int fallbackScore = 20;

        public int getStress5Score() {
            return stress5Score;
        }

        public void setStress5Score(int stress5Score) {
            this.stress5Score = stress5Score;
        }

        public int getStress10Score() {
            return stress10Score;
        }

        public void setStress10Score(int stress10Score) {
            this.stress10Score = stress10Score;
        }

        public int getStress20Score() {
            return stress20Score;
        }

        public void setStress20Score(int stress20Score) {
            this.stress20Score = stress20Score;
        }

        public int getStress30Score() {
            return stress30Score;
        }

        public void setStress30Score(int stress30Score) {
            this.stress30Score = stress30Score;
        }

        public int getFallbackScore() {
            return fallbackScore;
        }

        public void setFallbackScore(int fallbackScore) {
            this.fallbackScore = fallbackScore;
        }
    }

    public static class Fundamental {
        private int baseScore = 50;
        private MarketCap marketCap = new MarketCap();
        private Per per = new Per();
        private Eps eps = new Eps();
        private RevenueGrowth revenueGrowth = new RevenueGrowth();
        private OperatingMargin operatingMargin = new OperatingMargin();
        private Roe roe = new Roe();
        private DebtToEquity debtToEquity = new DebtToEquity();
        private Combination combination = new Combination();

        public int getBaseScore() {
            return baseScore;
        }

        public void setBaseScore(int baseScore) {
            this.baseScore = baseScore;
        }

        public MarketCap getMarketCap() {
            return marketCap;
        }

        public void setMarketCap(MarketCap marketCap) {
            this.marketCap = marketCap;
        }

        public Per getPer() {
            return per;
        }

        public void setPer(Per per) {
            this.per = per;
        }

        public Eps getEps() {
            return eps;
        }

        public void setEps(Eps eps) {
            this.eps = eps;
        }

        public RevenueGrowth getRevenueGrowth() {
            return revenueGrowth;
        }

        public void setRevenueGrowth(RevenueGrowth revenueGrowth) {
            this.revenueGrowth = revenueGrowth;
        }

        public OperatingMargin getOperatingMargin() {
            return operatingMargin;
        }

        public void setOperatingMargin(OperatingMargin operatingMargin) {
            this.operatingMargin = operatingMargin;
        }

        public Roe getRoe() {
            return roe;
        }

        public void setRoe(Roe roe) {
            this.roe = roe;
        }

        public DebtToEquity getDebtToEquity() {
            return debtToEquity;
        }

        public void setDebtToEquity(DebtToEquity debtToEquity) {
            this.debtToEquity = debtToEquity;
        }

        public Combination getCombination() {
            return combination;
        }

        public void setCombination(Combination combination) {
            this.combination = combination;
        }
    }

    public static class MarketCap {
        private double megaCapMin = 500_000;
        private int megaCapAdjustment = 20;
        private double largeCapMin = 200_000;
        private int largeCapAdjustment = 16;
        private double upperMidCapMin = 50_000;
        private int upperMidCapAdjustment = 10;
        private double midCapMin = 10_000;
        private int midCapAdjustment = 4;
        private int smallCapAdjustment = -4;

        public double getMegaCapMin() {
            return megaCapMin;
        }

        public void setMegaCapMin(double megaCapMin) {
            this.megaCapMin = megaCapMin;
        }

        public int getMegaCapAdjustment() {
            return megaCapAdjustment;
        }

        public void setMegaCapAdjustment(int megaCapAdjustment) {
            this.megaCapAdjustment = megaCapAdjustment;
        }

        public double getLargeCapMin() {
            return largeCapMin;
        }

        public void setLargeCapMin(double largeCapMin) {
            this.largeCapMin = largeCapMin;
        }

        public int getLargeCapAdjustment() {
            return largeCapAdjustment;
        }

        public void setLargeCapAdjustment(int largeCapAdjustment) {
            this.largeCapAdjustment = largeCapAdjustment;
        }

        public double getUpperMidCapMin() {
            return upperMidCapMin;
        }

        public void setUpperMidCapMin(double upperMidCapMin) {
            this.upperMidCapMin = upperMidCapMin;
        }

        public int getUpperMidCapAdjustment() {
            return upperMidCapAdjustment;
        }

        public void setUpperMidCapAdjustment(int upperMidCapAdjustment) {
            this.upperMidCapAdjustment = upperMidCapAdjustment;
        }

        public double getMidCapMin() {
            return midCapMin;
        }

        public void setMidCapMin(double midCapMin) {
            this.midCapMin = midCapMin;
        }

        public int getMidCapAdjustment() {
            return midCapAdjustment;
        }

        public void setMidCapAdjustment(int midCapAdjustment) {
            this.midCapAdjustment = midCapAdjustment;
        }

        public int getSmallCapAdjustment() {
            return smallCapAdjustment;
        }

        public void setSmallCapAdjustment(int smallCapAdjustment) {
            this.smallCapAdjustment = smallCapAdjustment;
        }
    }

    public static class Per {
        private double attractiveMax = 20;
        private int attractiveAdjustment = 12;
        private double fairMax = 35;
        private int fairAdjustment = 6;
        private double expensiveMax = 60;
        private int expensiveAdjustment = 0;
        private int veryExpensiveAdjustment = -10;
        private int negativeOrUnclearAdjustment = -8;

        public double getAttractiveMax() {
            return attractiveMax;
        }

        public void setAttractiveMax(double attractiveMax) {
            this.attractiveMax = attractiveMax;
        }

        public int getAttractiveAdjustment() {
            return attractiveAdjustment;
        }

        public void setAttractiveAdjustment(int attractiveAdjustment) {
            this.attractiveAdjustment = attractiveAdjustment;
        }

        public double getFairMax() {
            return fairMax;
        }

        public void setFairMax(double fairMax) {
            this.fairMax = fairMax;
        }

        public int getFairAdjustment() {
            return fairAdjustment;
        }

        public void setFairAdjustment(int fairAdjustment) {
            this.fairAdjustment = fairAdjustment;
        }

        public double getExpensiveMax() {
            return expensiveMax;
        }

        public void setExpensiveMax(double expensiveMax) {
            this.expensiveMax = expensiveMax;
        }

        public int getExpensiveAdjustment() {
            return expensiveAdjustment;
        }

        public void setExpensiveAdjustment(int expensiveAdjustment) {
            this.expensiveAdjustment = expensiveAdjustment;
        }

        public int getVeryExpensiveAdjustment() {
            return veryExpensiveAdjustment;
        }

        public void setVeryExpensiveAdjustment(int veryExpensiveAdjustment) {
            this.veryExpensiveAdjustment = veryExpensiveAdjustment;
        }

        public int getNegativeOrUnclearAdjustment() {
            return negativeOrUnclearAdjustment;
        }

        public void setNegativeOrUnclearAdjustment(int negativeOrUnclearAdjustment) {
            this.negativeOrUnclearAdjustment = negativeOrUnclearAdjustment;
        }
    }

    public static class Combination {
        private double positiveMarketCapMin = 50_000;
        private double positivePerMax = 35;
        private int positiveAdjustment = 4;
        private double negativeMarketCapMax = 10_000;
        private double negativePerMin = 60;
        private int negativeAdjustment = -4;
        private int qualityStackAdjustment = 6;
        private int fragileStackAdjustment = -6;

        public double getPositiveMarketCapMin() {
            return positiveMarketCapMin;
        }

        public void setPositiveMarketCapMin(double positiveMarketCapMin) {
            this.positiveMarketCapMin = positiveMarketCapMin;
        }

        public double getPositivePerMax() {
            return positivePerMax;
        }

        public void setPositivePerMax(double positivePerMax) {
            this.positivePerMax = positivePerMax;
        }

        public int getPositiveAdjustment() {
            return positiveAdjustment;
        }

        public void setPositiveAdjustment(int positiveAdjustment) {
            this.positiveAdjustment = positiveAdjustment;
        }

        public double getNegativeMarketCapMax() {
            return negativeMarketCapMax;
        }

        public void setNegativeMarketCapMax(double negativeMarketCapMax) {
            this.negativeMarketCapMax = negativeMarketCapMax;
        }

        public double getNegativePerMin() {
            return negativePerMin;
        }

        public void setNegativePerMin(double negativePerMin) {
            this.negativePerMin = negativePerMin;
        }

        public int getNegativeAdjustment() {
            return negativeAdjustment;
        }

        public void setNegativeAdjustment(int negativeAdjustment) {
            this.negativeAdjustment = negativeAdjustment;
        }

        public int getQualityStackAdjustment() {
            return qualityStackAdjustment;
        }

        public void setQualityStackAdjustment(int qualityStackAdjustment) {
            this.qualityStackAdjustment = qualityStackAdjustment;
        }

        public int getFragileStackAdjustment() {
            return fragileStackAdjustment;
        }

        public void setFragileStackAdjustment(int fragileStackAdjustment) {
            this.fragileStackAdjustment = fragileStackAdjustment;
        }
    }

    public static class Eps {
        private int positiveAdjustment = 8;
        private int negativeAdjustment = -14;

        public int getPositiveAdjustment() {
            return positiveAdjustment;
        }

        public void setPositiveAdjustment(int positiveAdjustment) {
            this.positiveAdjustment = positiveAdjustment;
        }

        public int getNegativeAdjustment() {
            return negativeAdjustment;
        }

        public void setNegativeAdjustment(int negativeAdjustment) {
            this.negativeAdjustment = negativeAdjustment;
        }
    }

    public static class RevenueGrowth {
        private double strongMin = 0.15;
        private double healthyMin = 0.05;
        private double flatMin = 0.0;
        private int strongAdjustment = 8;
        private int healthyAdjustment = 4;
        private int flatAdjustment = 0;
        private int negativeAdjustment = -8;

        public double getStrongMin() {
            return strongMin;
        }

        public void setStrongMin(double strongMin) {
            this.strongMin = strongMin;
        }

        public double getHealthyMin() {
            return healthyMin;
        }

        public void setHealthyMin(double healthyMin) {
            this.healthyMin = healthyMin;
        }

        public double getFlatMin() {
            return flatMin;
        }

        public void setFlatMin(double flatMin) {
            this.flatMin = flatMin;
        }

        public int getStrongAdjustment() {
            return strongAdjustment;
        }

        public void setStrongAdjustment(int strongAdjustment) {
            this.strongAdjustment = strongAdjustment;
        }

        public int getHealthyAdjustment() {
            return healthyAdjustment;
        }

        public void setHealthyAdjustment(int healthyAdjustment) {
            this.healthyAdjustment = healthyAdjustment;
        }

        public int getFlatAdjustment() {
            return flatAdjustment;
        }

        public void setFlatAdjustment(int flatAdjustment) {
            this.flatAdjustment = flatAdjustment;
        }

        public int getNegativeAdjustment() {
            return negativeAdjustment;
        }

        public void setNegativeAdjustment(int negativeAdjustment) {
            this.negativeAdjustment = negativeAdjustment;
        }
    }

    public static class OperatingMargin {
        private double strongMin = 0.25;
        private double healthyMin = 0.15;
        private double weakMin = 0.05;
        private int strongAdjustment = 8;
        private int healthyAdjustment = 4;
        private int weakAdjustment = 0;
        private int negativeAdjustment = -10;

        public double getStrongMin() {
            return strongMin;
        }

        public void setStrongMin(double strongMin) {
            this.strongMin = strongMin;
        }

        public double getHealthyMin() {
            return healthyMin;
        }

        public void setHealthyMin(double healthyMin) {
            this.healthyMin = healthyMin;
        }

        public double getWeakMin() {
            return weakMin;
        }

        public void setWeakMin(double weakMin) {
            this.weakMin = weakMin;
        }

        public int getStrongAdjustment() {
            return strongAdjustment;
        }

        public void setStrongAdjustment(int strongAdjustment) {
            this.strongAdjustment = strongAdjustment;
        }

        public int getHealthyAdjustment() {
            return healthyAdjustment;
        }

        public void setHealthyAdjustment(int healthyAdjustment) {
            this.healthyAdjustment = healthyAdjustment;
        }

        public int getWeakAdjustment() {
            return weakAdjustment;
        }

        public void setWeakAdjustment(int weakAdjustment) {
            this.weakAdjustment = weakAdjustment;
        }

        public int getNegativeAdjustment() {
            return negativeAdjustment;
        }

        public void setNegativeAdjustment(int negativeAdjustment) {
            this.negativeAdjustment = negativeAdjustment;
        }
    }

    public static class Roe {
        private double strongMin = 0.20;
        private double healthyMin = 0.10;
        private double weakMin = 0.0;
        private int strongAdjustment = 6;
        private int healthyAdjustment = 3;
        private int weakAdjustment = 0;
        private int negativeAdjustment = -8;

        public double getStrongMin() {
            return strongMin;
        }

        public void setStrongMin(double strongMin) {
            this.strongMin = strongMin;
        }

        public double getHealthyMin() {
            return healthyMin;
        }

        public void setHealthyMin(double healthyMin) {
            this.healthyMin = healthyMin;
        }

        public double getWeakMin() {
            return weakMin;
        }

        public void setWeakMin(double weakMin) {
            this.weakMin = weakMin;
        }

        public int getStrongAdjustment() {
            return strongAdjustment;
        }

        public void setStrongAdjustment(int strongAdjustment) {
            this.strongAdjustment = strongAdjustment;
        }

        public int getHealthyAdjustment() {
            return healthyAdjustment;
        }

        public void setHealthyAdjustment(int healthyAdjustment) {
            this.healthyAdjustment = healthyAdjustment;
        }

        public int getWeakAdjustment() {
            return weakAdjustment;
        }

        public void setWeakAdjustment(int weakAdjustment) {
            this.weakAdjustment = weakAdjustment;
        }

        public int getNegativeAdjustment() {
            return negativeAdjustment;
        }

        public void setNegativeAdjustment(int negativeAdjustment) {
            this.negativeAdjustment = negativeAdjustment;
        }
    }

    public static class DebtToEquity {
        private double conservativeMax = 0.8;
        private double balancedMax = 1.5;
        private double stretchedMax = 3.0;
        private int conservativeAdjustment = 4;
        private int balancedAdjustment = 1;
        private int stretchedAdjustment = -4;
        private int excessiveAdjustment = -8;

        public double getConservativeMax() {
            return conservativeMax;
        }

        public void setConservativeMax(double conservativeMax) {
            this.conservativeMax = conservativeMax;
        }

        public double getBalancedMax() {
            return balancedMax;
        }

        public void setBalancedMax(double balancedMax) {
            this.balancedMax = balancedMax;
        }

        public double getStretchedMax() {
            return stretchedMax;
        }

        public void setStretchedMax(double stretchedMax) {
            this.stretchedMax = stretchedMax;
        }

        public int getConservativeAdjustment() {
            return conservativeAdjustment;
        }

        public void setConservativeAdjustment(int conservativeAdjustment) {
            this.conservativeAdjustment = conservativeAdjustment;
        }

        public int getBalancedAdjustment() {
            return balancedAdjustment;
        }

        public void setBalancedAdjustment(int balancedAdjustment) {
            this.balancedAdjustment = balancedAdjustment;
        }

        public int getStretchedAdjustment() {
            return stretchedAdjustment;
        }

        public void setStretchedAdjustment(int stretchedAdjustment) {
            this.stretchedAdjustment = stretchedAdjustment;
        }

        public int getExcessiveAdjustment() {
            return excessiveAdjustment;
        }

        public void setExcessiveAdjustment(int excessiveAdjustment) {
            this.excessiveAdjustment = excessiveAdjustment;
        }
    }
}
