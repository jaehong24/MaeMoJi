package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.domain.NewsAnalysisCacheRecord;
import com.maemoji.backend.recommendation.domain.NewsAnalysisSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationEvidenceRecord;
import com.maemoji.backend.recommendation.domain.RecommendationEvidenceSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationRecord;
import com.maemoji.backend.recommendation.domain.RecommendationSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationTarget;
import com.maemoji.backend.recommendation.dto.RecommendationCalculationResponse;
import com.maemoji.backend.recommendation.dto.RecommendationEvidenceResponse;
import com.maemoji.backend.recommendation.dto.HomeRecommendationResponse;
import com.maemoji.backend.recommendation.dto.RecommendationResponse;
import com.maemoji.backend.recommendation.dto.RecommendationScoresResponse;
import com.maemoji.backend.recommendation.dto.RelatedNewsResponse;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.stock.domain.StockPriceSnapshotRecord;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import com.maemoji.backend.user.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class RecommendationService {

    private static final String DEV_USER_EMAIL = "dev@maemoji.local";
    private static final String ENGINE_VERSION = "RULE_V3_EXPLAINABLE_SCORE";
    private static final ZoneId HOME_ZONE = ZoneId.of("Asia/Seoul");
    private static final Set<String> HARD_RISK_KEYWORDS = Set.of(
            "fraud", "delist", "bankruptcy", "lawsuit", "investigation",
            "분식", "상장폐지", "파산", "소송", "회계부정", "조사"
    );

    private final RecommendationMapper recommendationMapper;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;
    private final NewsSentimentService newsSentimentService;
    private final RecommendationScoreCalculator scoreCalculator;
    private final StockPriceSnapshotMapper stockPriceSnapshotMapper;
    private final HttpClient httpClient;

    public RecommendationService(
            RecommendationMapper recommendationMapper,
            UserMapper userMapper,
            ObjectMapper objectMapper,
            NewsSentimentService newsSentimentService,
            RecommendationScoreCalculator scoreCalculator,
            StockPriceSnapshotMapper stockPriceSnapshotMapper
    ) {
        this.recommendationMapper = recommendationMapper;
        this.userMapper = userMapper;
        this.objectMapper = objectMapper;
        this.newsSentimentService = newsSentimentService;
        this.scoreCalculator = scoreCalculator;
        this.stockPriceSnapshotMapper = stockPriceSnapshotMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Transactional
    public List<RecommendationResponse> generateLatestRecommendations() {
        final Long userId = ensureDevUserId();
        final LocalDate recommendationDate = LocalDate.now();
        final List<RecommendationTarget> targets =
                recommendationMapper.findActiveRecommendationTargetsByUserId(userId);

        final List<RecommendationResponse> responses = new ArrayList<>();
        for (RecommendationTarget target : targets) {
            final EngineResult engineResult = evaluateTarget(target);
            final Long recommendationId = saveRecommendation(userId, target, recommendationDate, engineResult);
            responses.add(toResponse(target, recommendationId, engineResult));
        }

        return responses;
    }

    @Transactional
    public List<RecommendationResponse> getLatestRecommendations() {
        final Long userId = ensureDevUserId();
        final List<RecommendationTarget> targets =
                recommendationMapper.findActiveRecommendationTargetsByUserId(userId);

        if (targets.isEmpty()) {
            return List.of();
        }

        final List<RecommendationRecord> latestRecommendations =
                recommendationMapper.findLatestRecommendationsByUserId(userId);
        final Map<Long, RecommendationRecord> recommendationByPortfolioItemId = new LinkedHashMap<>();
        for (RecommendationRecord record : latestRecommendations) {
            recommendationByPortfolioItemId.put(record.getPortfolioItemId(), record);
        }

        return targets.stream()
                .map(target -> {
                    final RecommendationRecord record =
                            recommendationByPortfolioItemId.get(target.getPortfolioItemId());
                    return record != null
                            ? toResponse(record)
                            : toPendingResponse(target);
                })
                .toList();
    }

    @Transactional
    public HomeRecommendationResponse getLightweightHomeRecommendations() {
        final Long userId = ensureDevUserId();
        final List<RecommendationTarget> targets =
                recommendationMapper.findActiveRecommendationTargetsByUserId(userId);
        final List<LightweightRecommendationResult> results = targets.stream()
                .limit(5)
                .map(this::toLightweightHomeResponse)
                .toList();

        final LocalDate priceDataDate = results.stream()
                .map(LightweightRecommendationResult::priceDataDate)
                .filter(date -> date != null)
                .min(LocalDate::compareTo)
                .orElse(null);
        final OffsetDateTime newsAnalyzedAt = results.stream()
                .map(LightweightRecommendationResult::newsAnalyzedAt)
                .filter(analyzedAt -> analyzedAt != null)
                .min(OffsetDateTime::compareTo)
                .orElse(null);

        return new HomeRecommendationResponse(
                OffsetDateTime.now(HOME_ZONE),
                priceDataDate,
                newsAnalyzedAt,
                results.stream().map(LightweightRecommendationResult::response).toList()
        );
    }

    private EngineResult evaluateTarget(RecommendationTarget target) {
        final BigDecimal currentAmount = safeAmount(target.getDailyInvestAmount());
        final String memo = blankToEmpty(target.getMemo());
        final boolean hasHardRisk = containsHardRiskKeyword(memo);

        final PriceSnapshot priceSnapshot = fetchPriceSnapshot(target);
        final NewsSentimentService.NewsSentimentResult newsSentiment =
                newsSentimentService.analyze(
                        target.getStockId(),
                        resolveSymbol(target),
                        target.getCompanyName()
                );

        final int confidenceScore = resolveConfidence(target, priceSnapshot, newsSentiment);
        final Integer rawNewsSentiment = newsSentiment.relatedNews().isEmpty()
                ? null
                : newsSentiment.weightedSentimentScore();
        final RecommendationScoreCalculator.ScoreResult scoreResult = scoreCalculator.calculate(
                priceSnapshot.thirtyDayReturn(),
                rawNewsSentiment,
                priceSnapshot.hasSevereDrop() || hasHardRisk,
                newsSentiment.hardNegativeOverride(),
                confidenceScore
        );
        final int finalScore = scoreResult.finalScore();
        final String recommendationStatus = scoreResult.recommendationStatus();
        final int priceContribution = weightedContribution(
                scoreResult.priceScore(),
                scoreResult.priceWeight(),
                scoreResult.priceWeight() + scoreResult.newsWeight()
        );
        final int newsContribution = weightedContribution(
                scoreResult.newsScore(),
                scoreResult.newsWeight(),
                scoreResult.priceWeight() + scoreResult.newsWeight()
        );

        final BigDecimal recommendedAmount = resolveRecommendedAmount(currentAmount, recommendationStatus);
        final List<RecommendationEvidenceSaveCommand> evidence = buildV3Evidence(
                target,
                priceSnapshot,
                newsSentiment,
                scoreResult,
                priceContribution,
                newsContribution
        );
        final String finalNote = buildFinalNote(target, recommendationStatus, finalScore, priceSnapshot, newsSentiment);

        return new EngineResult(
                recommendationStatus,
                finalScore,
                confidenceScore,
                currentAmount,
                recommendedAmount,
                finalNote,
                0,
                0,
                priceContribution,
                newsContribution,
                0,
                evidence,
                newsSentiment.relatedNews(),
                newsSentiment.llmModel(),
                newsSentiment.analysisConfidence(),
                newsSentiment.cacheReused(),
                newsSentiment.replaceCache(),
                scoreResult
        );
    }

    private Long saveRecommendation(
            Long userId,
            RecommendationTarget target,
            LocalDate recommendationDate,
            EngineResult engineResult
    ) {
        final RecommendationSaveCommand command = new RecommendationSaveCommand();
        command.setUserId(userId);
        command.setPortfolioItemId(target.getPortfolioItemId());
        command.setRecommendationDate(recommendationDate);
        command.setRecommendationStatus(engineResult.recommendationStatus());
        command.setEngineScore(engineResult.finalScore());
        command.setConfidenceScore(engineResult.confidenceScore());
        command.setCurrentAmount(engineResult.currentAmount());
        command.setRecommendedAmount(engineResult.recommendedAmount());
        command.setFinalNote(engineResult.finalNote());
        command.setEngineVersion(ENGINE_VERSION);
        command.setFormulaVersion(RecommendationScoreCalculator.FORMULA_VERSION);
        command.setRawScore(engineResult.scoreResult().rawScore());
        command.setRiskAdjustment(engineResult.scoreResult().riskAdjustment());
        command.setPriceScore(engineResult.scoreResult().priceScore());
        command.setNewsScore(engineResult.scoreResult().newsScore());
        command.setPriceWeight(engineResult.scoreResult().priceWeight());
        command.setNewsWeight(engineResult.scoreResult().newsWeight());
        command.setPriceReturn30d(decimalOrNull(engineResult.scoreResult().thirtyDayReturn()));
        command.setNewsSentimentScore(engineResult.scoreResult().newsSentimentScore());
        command.setIncreaseEligible(engineResult.scoreResult().increaseEligible());

        final Long recommendationId = recommendationMapper.upsertRecommendation(command);
        command.setRecommendationId(recommendationId);
        recommendationMapper.deleteRecommendationEvidence(recommendationId);
        for (RecommendationEvidenceSaveCommand evidenceCommand : engineResult.evidence()) {
            evidenceCommand.setRecommendationId(recommendationId);
            recommendationMapper.insertRecommendationEvidence(evidenceCommand);
        }

        if (engineResult.replaceNewsCache()) {
            recommendationMapper.deleteNewsAnalysisCacheByStockId(target.getStockId());
            for (NewsSentimentService.AnalyzedNewsItem newsItem : engineResult.relatedNews()) {
                final NewsAnalysisSaveCommand newsCommand = new NewsAnalysisSaveCommand();
                newsCommand.setStockId(target.getStockId());
                newsCommand.setNewsId(newsItem.newsId());
                newsCommand.setSymbol(newsItem.symbol());
                newsCommand.setNewsPublishedAt(newsItem.newsPublishedAt());
                newsCommand.setHeadline(newsItem.headline());
                newsCommand.setSummary(newsItem.summary());
                newsCommand.setSourceName(newsItem.sourceName());
                newsCommand.setNewsUrl(newsItem.newsUrl());
                newsCommand.setSentimentLabel(newsItem.sentimentLabel());
                newsCommand.setSentimentScore(newsItem.sentimentScore());
                newsCommand.setKeywordScore(newsItem.keywordScore());
                newsCommand.setRelevanceScore(newsItem.relevanceScore());
                newsCommand.setImpactLevel(newsItem.impactLevel());
                newsCommand.setReason(newsItem.reason());
                newsCommand.setRecencyWeight(newsItem.recencyWeight());
                newsCommand.setImpactWeight(newsItem.impactWeight());
                newsCommand.setWeightedScore(newsItem.weightedScore());
                newsCommand.setContentHash(newsItem.contentHash());
                newsCommand.setAnalysisBatchHash(newsItem.analysisBatchHash());
                newsCommand.setLlmModel(engineResult.llmModel());
                newsCommand.setAnalyzedAt(OffsetDateTime.now(ZoneOffset.UTC));
                recommendationMapper.insertNewsAnalysisCache(newsCommand);
            }
        }

        return recommendationId;
    }

    private LightweightRecommendationResult toLightweightHomeResponse(RecommendationTarget target) {
        final StockPriceSnapshotRecord snapshot =
                stockPriceSnapshotMapper.findLatestSnapshotByStockId(target.getStockId());
        final List<NewsAnalysisCacheRecord> cachedNews =
                recommendationMapper.findLatestNewsAnalysisByStockId(target.getStockId());
        final CachedNewsSummary newsSummary = summarizeCachedNews(cachedNews);
        final Double thirtyDayReturn = snapshot == null || snapshot.getChangeRate30d() == null
                ? null
                : snapshot.getChangeRate30d().doubleValue();
        final boolean hardStopRisk = (thirtyDayReturn != null && thirtyDayReturn <= -35)
                || containsHardRiskKeyword(blankToEmpty(target.getMemo()));
        final int confidence = resolveLightweightConfidence(target, snapshot, newsSummary);
        final RecommendationScoreCalculator.ScoreResult scoreResult = scoreCalculator.calculate(
                thirtyDayReturn,
                newsSummary.sentimentScore(),
                hardStopRisk,
                newsSummary.hardNegative(),
                confidence
        );
        final BigDecimal currentAmount = safeAmount(target.getDailyInvestAmount());
        final BigDecimal recommendedAmount = resolveRecommendedAmount(
                currentAmount,
                scoreResult.recommendationStatus()
        );
        final List<RecommendationEvidenceResponse> evidence = buildLightweightEvidence(
                scoreResult,
                newsSummary
        );

        final RecommendationResponse response = new RecommendationResponse(
                null,
                target.getPortfolioItemId(),
                target.getStockId(),
                target.getCompanyName(),
                target.getTicker(),
                target.getLogoUrl(),
                scoreResult.recommendationStatus(),
                scoreResult.finalScore(),
                confidence,
                currentAmount,
                recommendedAmount,
                formatHoldingQuantity(target.getHoldingQuantity()),
                target.getInvestmentStartDate() == null ? "" : target.getInvestmentStartDate().toString(),
                blankToEmpty(target.getMemo()),
                buildLightweightNote(target, scoreResult, newsSummary),
                "HOME_LIGHT_V1",
                new RecommendationScoresResponse(
                        0,
                        0,
                        scoreResult.priceScore() == null ? 0 : scoreResult.priceScore(),
                        scoreResult.newsScore() == null ? 0 : scoreResult.newsScore(),
                        0
                ),
                toCalculationResponse(scoreResult),
                evidence,
                cachedNews.stream().map(this::toRelatedNewsResponse).toList()
        );
        final OffsetDateTime newsAnalyzedAt = cachedNews.stream()
                .map(NewsAnalysisCacheRecord::getAnalyzedAt)
                .filter(analyzedAt -> analyzedAt != null)
                .min(OffsetDateTime::compareTo)
                .orElse(null);
        return new LightweightRecommendationResult(
                response,
                snapshot == null ? null : snapshot.getSnapshotDate(),
                newsAnalyzedAt
        );
    }

    private CachedNewsSummary summarizeCachedNews(List<NewsAnalysisCacheRecord> cachedNews) {
        if (cachedNews.isEmpty()) {
            return new CachedNewsSummary(null, false, 0);
        }

        double weightedTotal = 0;
        double totalWeight = 0;
        double relevanceTotal = 0;
        boolean hardNegative = false;

        for (NewsAnalysisCacheRecord record : cachedNews) {
            final int sentiment = zeroIfNull(record.getSentimentScore());
            final int relevance = zeroIfNull(record.getRelevanceScore());
            final double recencyWeight = record.getRecencyWeight() == null
                    ? 1.0
                    : record.getRecencyWeight().doubleValue();
            final double impactWeight = record.getImpactWeight() == null
                    ? 1.0
                    : record.getImpactWeight().doubleValue();
            final double weight = relevance / 100.0 * recencyWeight * impactWeight;
            weightedTotal += sentiment * weight;
            totalWeight += weight;
            relevanceTotal += relevance;
            hardNegative = hardNegative
                    || (zeroIfNull(record.getKeywordScore()) <= -85
                    && relevance >= 60
                    && "HIGH".equals(record.getImpactLevel()));
        }

        final Integer sentimentScore = totalWeight == 0
                ? null
                : (int) Math.round(weightedTotal / totalWeight);
        final int confidence = Math.min(
                95,
                (int) Math.round(40 + cachedNews.size() * 10 + relevanceTotal / cachedNews.size() * 0.3)
        );
        return new CachedNewsSummary(sentimentScore, hardNegative, confidence);
    }

    private int resolveLightweightConfidence(
            RecommendationTarget target,
            StockPriceSnapshotRecord snapshot,
            CachedNewsSummary newsSummary
    ) {
        int confidence = 50;
        if (snapshot != null && snapshot.getCurrentPrice() != null) {
            confidence += 5;
        }
        if (snapshot != null && snapshot.getChangeRate30d() != null) {
            confidence += 10;
        }
        if (target.getInvestmentStartDate() != null) {
            confidence += 5;
        }
        if (!blankToEmpty(target.getMemo()).isBlank()) {
            confidence += 5;
        }
        if (newsSummary.sentimentScore() != null) {
            confidence += Math.round(newsSummary.confidence() / 10.0f);
        }
        return Math.min(confidence, 90);
    }

    private List<RecommendationEvidenceResponse> buildLightweightEvidence(
            RecommendationScoreCalculator.ScoreResult scoreResult,
            CachedNewsSummary newsSummary
    ) {
        final List<RecommendationEvidenceResponse> evidence = new ArrayList<>();
        evidence.add(new RecommendationEvidenceResponse(
                "PRICE",
                "30일 가격 흐름",
                scoreResult.thirtyDayReturn() == null
                        ? "아직 30일 가격 이력이 충분하지 않아 가격 점수에서 제외했습니다."
                        : "DB에 누적된 30일 수익률 "
                        + formatSignedPercent(scoreResult.thirtyDayReturn())
                        + "를 반영했습니다.",
                scoreResult.priceScore(),
                1
        ));
        evidence.add(new RecommendationEvidenceResponse(
                "NEWS_CACHE",
                "저장된 뉴스 분석",
                newsSummary.sentimentScore() == null
                        ? "저장된 관련 뉴스 분석이 없어 뉴스 점수에서 제외했습니다."
                        : "최근 저장된 Gemini 뉴스 분석 점수 "
                        + formatSignedNumber(newsSummary.sentimentScore())
                        + "를 재사용했습니다.",
                scoreResult.newsScore(),
                2
        ));
        return evidence;
    }

    private String buildLightweightNote(
            RecommendationTarget target,
            RecommendationScoreCalculator.ScoreResult scoreResult,
            CachedNewsSummary newsSummary
    ) {
        final String newsText = newsSummary.sentimentScore() == null
                ? "저장된 뉴스 분석 없이"
                : "저장된 뉴스 분석과";
        return target.getCompanyName()
                + "은 "
                + newsText
                + " DB 가격 데이터를 기준으로 빠르게 갱신한 결과입니다. 현재 판단은 "
                + scoreResult.recommendationStatus()
                + "입니다.";
    }

    private RecommendationResponse toResponse(
            RecommendationTarget target,
            Long recommendationId,
            EngineResult engineResult
    ) {
        return new RecommendationResponse(
                recommendationId,
                target.getPortfolioItemId(),
                target.getStockId(),
                target.getCompanyName(),
                target.getTicker(),
                target.getLogoUrl(),
                engineResult.recommendationStatus(),
                engineResult.finalScore(),
                engineResult.confidenceScore(),
                engineResult.currentAmount(),
                engineResult.recommendedAmount(),
                formatHoldingQuantity(target.getHoldingQuantity()),
                target.getInvestmentStartDate() == null ? "" : target.getInvestmentStartDate().toString(),
                blankToEmpty(target.getMemo()),
                engineResult.finalNote(),
                ENGINE_VERSION,
                new RecommendationScoresResponse(
                        engineResult.businessHealthScore(),
                        engineResult.valuationScore(),
                        engineResult.priceOverheatingScore(),
                        engineResult.newsSentimentScore(),
                        engineResult.institutionalConfidenceScore()
                ),
                toCalculationResponse(engineResult.scoreResult()),
                engineResult.evidence().stream()
                        .map(this::toEvidenceResponse)
                        .toList(),
                engineResult.relatedNews().stream()
                        .map(this::toRelatedNewsResponse)
                        .toList()
        );
    }

    private RecommendationResponse toResponse(RecommendationRecord record) {
        final List<RecommendationEvidenceRecord> evidenceRecords =
                recommendationMapper.findRecommendationEvidenceByRecommendationId(record.getRecommendationId());
        final List<NewsAnalysisCacheRecord> newsRecords =
                recommendationMapper.findLatestNewsAnalysisByStockId(record.getStockId());

        return new RecommendationResponse(
                record.getRecommendationId(),
                record.getPortfolioItemId(),
                record.getStockId(),
                record.getCompanyName(),
                record.getTicker(),
                record.getLogoUrl(),
                record.getRecommendationStatus(),
                zeroIfNull(record.getEngineScore()),
                zeroIfNull(record.getConfidenceScore()),
                safeAmount(record.getCurrentAmount()),
                safeAmount(record.getRecommendedAmount()),
                formatHoldingQuantity(record.getHoldingQuantity()),
                record.getInvestmentStartDate() == null ? "" : record.getInvestmentStartDate().toString(),
                blankToEmpty(record.getMemo()),
                blankToEmpty(record.getFinalNote()),
                blankToEmpty(record.getEngineVersion()),
                extractScores(evidenceRecords),
                toCalculationResponse(record),
                evidenceRecords.stream()
                        .map(this::toEvidenceResponse)
                        .toList(),
                newsRecords.stream()
                        .map(this::toRelatedNewsResponse)
                        .toList()
        );
    }

    private RecommendationResponse toPendingResponse(RecommendationTarget target) {
        final BigDecimal currentAmount = safeAmount(target.getDailyInvestAmount());
        final List<RecommendationEvidenceResponse> evidence = List.of(
                new RecommendationEvidenceResponse(
                        "PENDING",
                        "추천 분석 대기",
                        "홈 화면에서는 저장된 추천 결과만 빠르게 보여줍니다. 상세 분석이 필요하면 추천 생성 시 최신 분석을 불러옵니다.",
                        null,
                        1
                )
        );

        return new RecommendationResponse(
                null,
                target.getPortfolioItemId(),
                target.getStockId(),
                target.getCompanyName(),
                target.getTicker(),
                target.getLogoUrl(),
                "MAINTAIN",
                50,
                55,
                currentAmount,
                currentAmount,
                formatHoldingQuantity(target.getHoldingQuantity()),
                target.getInvestmentStartDate() == null ? "" : target.getInvestmentStartDate().toString(),
                blankToEmpty(target.getMemo()),
                "상세 분석 전까지는 현재 모으기 금액을 유지하는 기본 상태로 표시합니다.",
                "PENDING",
                new RecommendationScoresResponse(0, 0, 0, 0, 0),
                new RecommendationCalculationResponse(
                        "PENDING",
                        50,
                        50,
                        0,
                        null,
                        null,
                        0,
                        0,
                        null,
                        null,
                        false
                ),
                evidence,
                List.of()
        );
    }

    private RecommendationScoresResponse extractScores(List<RecommendationEvidenceRecord> evidenceRecords) {
        final Map<String, Integer> scoreMap = evidenceRecords.stream()
                .filter(record -> record.getScoreImpact() != null)
                .collect(Collectors.toMap(
                        RecommendationEvidenceRecord::getEvidenceType,
                        RecommendationEvidenceRecord::getScoreImpact,
                        (left, right) -> left
                ));

        return new RecommendationScoresResponse(
                scoreMap.getOrDefault("EARNINGS", 0),
                scoreMap.getOrDefault("VALUATION", 0),
                scoreMap.getOrDefault("PRICE", 0),
                scoreMap.getOrDefault("NEWS", 0),
                scoreMap.getOrDefault("INSTITUTION", 0)
        );
    }

    private RecommendationEvidenceResponse toEvidenceResponse(RecommendationEvidenceSaveCommand command) {
        return new RecommendationEvidenceResponse(
                command.getEvidenceType(),
                command.getTitle(),
                command.getBody(),
                command.getScoreImpact(),
                command.getDisplayOrder()
        );
    }

    private RecommendationEvidenceResponse toEvidenceResponse(RecommendationEvidenceRecord record) {
        return new RecommendationEvidenceResponse(
                record.getEvidenceType(),
                record.getTitle(),
                record.getBody(),
                record.getScoreImpact(),
                record.getDisplayOrder()
        );
    }

    private RelatedNewsResponse toRelatedNewsResponse(NewsSentimentService.AnalyzedNewsItem item) {
        return new RelatedNewsResponse(
                item.headline(),
                item.summary(),
                item.sourceName(),
                item.newsUrl(),
                item.sentimentLabel(),
                item.sentimentScore(),
                item.relevanceScore(),
                item.impactLevel(),
                item.reason(),
                item.weightedScore()
        );
    }

    private RelatedNewsResponse toRelatedNewsResponse(NewsAnalysisCacheRecord record) {
        return new RelatedNewsResponse(
                record.getHeadline(),
                record.getSummary(),
                record.getSourceName(),
                record.getNewsUrl(),
                record.getSentimentLabel(),
                record.getSentimentScore(),
                record.getRelevanceScore(),
                record.getImpactLevel(),
                record.getReason(),
                record.getWeightedScore()
        );
    }

    private RecommendationCalculationResponse toCalculationResponse(
            RecommendationScoreCalculator.ScoreResult result
    ) {
        return new RecommendationCalculationResponse(
                RecommendationScoreCalculator.FORMULA_VERSION,
                result.rawScore(),
                result.finalScore(),
                result.riskAdjustment(),
                result.priceScore(),
                result.newsScore(),
                result.priceWeight(),
                result.newsWeight(),
                result.thirtyDayReturn(),
                result.newsSentimentScore(),
                result.increaseEligible()
        );
    }

    private RecommendationCalculationResponse toCalculationResponse(RecommendationRecord record) {
        return new RecommendationCalculationResponse(
                blankToEmpty(record.getFormulaVersion()),
                zeroIfNull(record.getRawScore()),
                zeroIfNull(record.getEngineScore()),
                zeroIfNull(record.getRiskAdjustment()),
                record.getPriceScore(),
                record.getNewsScore(),
                zeroIfNull(record.getPriceWeight()),
                zeroIfNull(record.getNewsWeight()),
                record.getPriceReturn30d() == null
                        ? null
                        : record.getPriceReturn30d().doubleValue(),
                record.getNewsSentimentScore(),
                Boolean.TRUE.equals(record.getIncreaseEligible())
        );
    }

    private List<RecommendationEvidenceSaveCommand> buildV3Evidence(
            RecommendationTarget target,
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment,
            RecommendationScoreCalculator.ScoreResult scoreResult,
            int priceContribution,
            int newsContribution
    ) {
        final List<RecommendationEvidenceSaveCommand> evidence = new ArrayList<>();
        evidence.add(evidence(
                "PRICE",
                "30일 가격 흐름",
                priceSnapshot.hasThirtyDayReturn()
                        ? "최근 30일 수익률 "
                                + formatSignedPercent(priceSnapshot.thirtyDayReturn())
                                + "를 가격 점수 "
                                + scoreResult.priceScore()
                                + "점으로 변환했습니다."
                        : "가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.",
                scoreResult.priceScore() == null ? null : priceContribution,
                1
        ));
        evidence.add(evidence(
                "NEWS",
                "관련 뉴스 분석",
                scoreResult.newsScore() == null
                        ? "오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다."
                        : newsSentiment.summary()
                                + " Gemini 종합 감성 "
                                + formatSignedNumber(scoreResult.newsSentimentScore())
                                + "점을 정규화해 뉴스 점수 "
                                + scoreResult.newsScore()
                                + "점으로 계산했습니다.",
                scoreResult.newsScore() == null ? null : newsContribution,
                2
        ));
        evidence.add(evidence(
                "FORMULA",
                "최종 점수 계산",
                "사용 가능한 데이터만 가중 평균했습니다. 가격 "
                        + scoreResult.priceWeight()
                        + "%, 뉴스 "
                        + scoreResult.newsWeight()
                        + "%를 적용해 원점수 "
                        + scoreResult.rawScore()
                        + "점, 위험 조정 "
                        + formatSignedNumber(scoreResult.riskAdjustment())
                        + "점, 최종 "
                        + scoreResult.finalScore()
                        + "점입니다.",
                scoreResult.riskAdjustment(),
                3
        ));
        evidence.add(evidence(
                "AI_NOTE",
                "최종 해석",
                buildAiComment(
                        target,
                        scoreResult.recommendationStatus(),
                        scoreResult.finalScore(),
                        priceSnapshot,
                        newsSentiment
                ),
                null,
                4
        ));
        return evidence;
    }

    private List<RecommendationEvidenceSaveCommand> buildEvidence(
            RecommendationTarget target,
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment,
            int businessHealthScore,
            int valuationScore,
            int priceOverheatingScore,
            int newsSentimentScore,
            int institutionalConfidenceScore,
            int finalScore,
            String recommendationStatus
    ) {
        final List<RecommendationEvidenceSaveCommand> evidence = new ArrayList<>();
        evidence.add(evidence(
                "EARNINGS",
                "사업 건전성",
                "재무제표와 실적 성장률은 아직 정식 연동 전이라, 1차 엔진에서는 중립 점수 24/35를 적용했습니다.",
                businessHealthScore,
                1
        ));
        evidence.add(evidence(
                "VALUATION",
                "밸류에이션",
                "업종 평균 PER/PBR 비교 데이터가 아직 없어 보수적인 중립 점수 13/20으로 반영했습니다.",
                valuationScore,
                2
        ));
        evidence.add(evidence(
                "PRICE",
                "가격 과열도",
                buildPriceEvidence(priceSnapshot),
                priceOverheatingScore,
                3
        ));
        evidence.add(evidence(
                "NEWS",
                "뉴스 심리",
                newsSentiment.summary()
                        + " 종목별 가중 감성 점수는 "
                        + formatSignedNumber(newsSentiment.weightedSentimentScore())
                        + "점이며 분석 신뢰도는 "
                        + newsSentiment.analysisConfidence()
                        + "%입니다.",
                newsSentimentScore,
                4
        ));
        evidence.add(evidence(
                "INSTITUTION",
                "기관 신뢰도",
                "기관 보유 변동과 13F 데이터는 아직 연동 전이라 중립 점수 10/15로 처리했습니다.",
                institutionalConfidenceScore,
                5
        ));
        evidence.add(evidence(
                "AI_NOTE",
                "최종 해석",
                buildAiComment(target, recommendationStatus, finalScore, priceSnapshot, newsSentiment),
                null,
                6
        ));
        return evidence;
    }

    private RecommendationEvidenceSaveCommand evidence(
            String type,
            String title,
            String body,
            Integer scoreImpact,
            Integer displayOrder
    ) {
        final RecommendationEvidenceSaveCommand command = new RecommendationEvidenceSaveCommand();
        command.setEvidenceType(type);
        command.setTitle(title);
        command.setBody(body);
        command.setScoreImpact(scoreImpact);
        command.setDisplayOrder(displayOrder);
        return command;
    }

    private String buildPriceEvidence(PriceSnapshot priceSnapshot) {
        if (!priceSnapshot.hasThirtyDayReturn()) {
            return "최근 30일 가격 데이터가 아직 충분하지 않아 가격 과열도는 중립 점수 10/15로 반영했습니다.";
        }

        return "최근 30일 수익률은 " + formatSignedPercent(priceSnapshot.thirtyDayReturn())
                + "이며, 이 값을 기준으로 가격 과열도 점수를 계산했습니다.";
    }

    private String buildAiComment(
            RecommendationTarget target,
            String recommendationStatus,
            int finalScore,
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment
    ) {
        final String companyName = target.getCompanyName();

        if ("STOP".equals(recommendationStatus)) {
            return companyName + "은 현재 데이터 기준으로 리스크 관리가 우선이라, 매수보다 중단 또는 관망 쪽에 더 가까운 상태입니다.";
        }
        if (newsSentiment.hardNegativeOverride()) {
            return companyName + "과 직접 관련된 강한 악재가 확인되어, 다른 긍정 기사보다 우선 반영하고 모으기 금액 축소를 권합니다.";
        }
        if ("REDUCE".equals(recommendationStatus)) {
            return companyName + "은 현재 점수 " + finalScore
                    + "점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.";
        }
        if ("NEGATIVE".equals(newsSentiment.label())) {
            return companyName + "은 최근 뉴스 심리가 부정적으로 기울어 있어, 당장 증액보다 현재 금액 유지가 더 안전합니다.";
        }
        if (priceSnapshot.hasThirtyDayReturn() && priceSnapshot.thirtyDayReturn() >= 10) {
            return companyName + "은 최근 단기 상승 폭이 있어, 지금은 무리한 증액보다 현재 금액 유지가 더 적절합니다.";
        }

        return companyName + "은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.";
    }

    private String buildFinalNote(
            RecommendationTarget target,
            String recommendationStatus,
            int finalScore,
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment
    ) {
        return buildAiComment(target, recommendationStatus, finalScore, priceSnapshot, newsSentiment);
    }

    private String resolveRecommendationStatus(int finalScore) {
        if (finalScore >= 85) {
            return "INCREASE";
        }
        if (finalScore >= 65) {
            return "MAINTAIN";
        }
        if (finalScore >= 45) {
            return "REDUCE";
        }
        return "STOP";
    }

    private BigDecimal resolveRecommendedAmount(BigDecimal currentAmount, String recommendationStatus) {
        return switch (recommendationStatus) {
            case "INCREASE" -> scale(currentAmount.multiply(BigDecimal.valueOf(1.2)));
            case "MAINTAIN" -> scale(currentAmount);
            case "REDUCE" -> scale(currentAmount.multiply(BigDecimal.valueOf(0.7)));
            default -> BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        };
    }

    private int resolveConfidence(
            RecommendationTarget target,
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment
    ) {
        int confidence = 55;

        if (priceSnapshot.hasCurrentPrice()) {
            confidence += 5;
        }
        if (priceSnapshot.hasThirtyDayReturn()) {
            confidence += 10;
        }
        if (target.getInvestmentStartDate() != null) {
            confidence += 5;
        }
        if (!blankToEmpty(target.getMemo()).isBlank()) {
            confidence += 5;
        }
        if (!newsSentiment.relatedNews().isEmpty()) {
            confidence += Math.round(newsSentiment.analysisConfidence() / 10.0f);
        }

        return Math.min(confidence, 90);
    }

    private int resolvePriceOverheatingScore(Double thirtyDayReturn) {
        if (thirtyDayReturn == null) {
            return 10;
        }
        if (thirtyDayReturn >= 30) {
            return 0;
        }
        if (thirtyDayReturn >= 10) {
            return 6;
        }
        if (thirtyDayReturn >= -10) {
            return 10;
        }
        if (thirtyDayReturn >= -20) {
            return 12;
        }
        return 5;
    }

    private PriceSnapshot fetchPriceSnapshot(RecommendationTarget target) {
        final StockPriceSnapshotRecord latestSnapshot =
                stockPriceSnapshotMapper.findLatestSnapshotByStockId(target.getStockId());
        if (latestSnapshot != null
                && latestSnapshot.getCurrentPrice() != null
                && latestSnapshot.getCurrentPrice().doubleValue() > 0) {
            return new PriceSnapshot(
                    latestSnapshot.getCurrentPrice().doubleValue(),
                    latestSnapshot.getChangeRate30d() == null
                            ? null
                            : latestSnapshot.getChangeRate30d().doubleValue()
            );
        }

        final String apiKey = System.getenv("FINNHUB_API_KEY");
        final String symbol = resolveSymbol(target);

        if (blankToEmpty(apiKey).isBlank() || blankToEmpty(symbol).isBlank()) {
            return PriceSnapshot.unavailable();
        }

        try {
            final Double currentPrice = fetchCurrentPrice(symbol, apiKey);
            return new PriceSnapshot(currentPrice, null);
        } catch (Exception ignored) {
            return PriceSnapshot.unavailable();
        }
    }

    private String resolveSymbol(RecommendationTarget target) {
        return !blankToEmpty(target.getFinnhubSymbol()).isBlank()
                ? target.getFinnhubSymbol()
                : target.getTicker();
    }

    private Double fetchCurrentPrice(String symbol, String apiKey) throws Exception {
        final String uri = "https://finnhub.io/api/v1/quote?symbol="
                + encode(symbol)
                + "&token="
                + encode(apiKey);

        final JsonNode body = getJson(uri);
        if (body == null || !body.has("c")) {
            return null;
        }

        final double currentPrice = body.path("c").asDouble(0);
        return currentPrice > 0 ? currentPrice : null;
    }

    private JsonNode getJson(String uri) throws Exception {
        final HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(uri))
                .timeout(Duration.ofSeconds(15))
                .GET()
                .build();

        final HttpResponse<String> response = httpClient.send(
                request,
                HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
        );

        if (response.statusCode() != 200 || response.body().isBlank()) {
            return null;
        }

        return objectMapper.readTree(response.body());
    }

    private boolean containsHardRiskKeyword(String memo) {
        final String lowered = memo.toLowerCase(Locale.ROOT);
        return HARD_RISK_KEYWORDS.stream().anyMatch(lowered::contains);
    }

    private String formatSignedPercent(Double value) {
        if (value == null) {
            return "데이터 없음";
        }
        return String.format(Locale.US, "%+.1f%%", value);
    }

    private String formatSignedNumber(int value) {
        return String.format(Locale.US, "%+d", value);
    }

    private String formatHoldingQuantity(BigDecimal holdingQuantity) {
        if (holdingQuantity == null) {
            return "-";
        }
        return holdingQuantity.stripTrailingZeros().toPlainString() + "주";
    }

    private BigDecimal safeAmount(BigDecimal amount) {
        if (amount == null) {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        return scale(amount);
    }

    private BigDecimal scale(BigDecimal amount) {
        return amount.setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal decimalOrNull(Double value) {
        return value == null
                ? null
                : BigDecimal.valueOf(value).setScale(4, RoundingMode.HALF_UP);
    }

    private int weightedContribution(Integer score, int weight, int totalWeight) {
        if (score == null || weight == 0 || totalWeight == 0) {
            return 0;
        }
        return (int) Math.round(score * weight / (double) totalWeight);
    }

    private Integer zeroIfNull(Integer value) {
        return value == null ? 0 : value;
    }

    private String blankToEmpty(String value) {
        return value == null ? "" : value;
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private Long ensureDevUserId() {
        Long userId = userMapper.findIdByEmail(DEV_USER_EMAIL);
        if (userId != null) {
            return userId;
        }

        userMapper.insertDevUser();
        userId = userMapper.findIdByEmail(DEV_USER_EMAIL);
        if (userId == null) {
            throw new IllegalStateException("개발용 사용자 ID를 찾을 수 없습니다.");
        }

        return userId;
    }

    private record EngineResult(
            String recommendationStatus,
            int finalScore,
            int confidenceScore,
            BigDecimal currentAmount,
            BigDecimal recommendedAmount,
            String finalNote,
            int businessHealthScore,
            int valuationScore,
            int priceOverheatingScore,
            int newsSentimentScore,
            int institutionalConfidenceScore,
            List<RecommendationEvidenceSaveCommand> evidence,
            List<NewsSentimentService.AnalyzedNewsItem> relatedNews,
            String llmModel,
            int newsAnalysisConfidence,
            boolean newsCacheReused,
            boolean replaceNewsCache,
            RecommendationScoreCalculator.ScoreResult scoreResult
    ) {
    }

    private record PriceSnapshot(
            Double currentPrice,
            Double thirtyDayReturn
    ) {
        static PriceSnapshot unavailable() {
            return new PriceSnapshot(null, null);
        }

        boolean hasCurrentPrice() {
            return currentPrice != null && currentPrice > 0;
        }

        boolean hasThirtyDayReturn() {
            return thirtyDayReturn != null;
        }

        boolean hasSevereDrop() {
            return thirtyDayReturn != null && thirtyDayReturn <= -35;
        }
    }

    private record CachedNewsSummary(
            Integer sentimentScore,
            boolean hardNegative,
            int confidence
    ) {
    }

    private record LightweightRecommendationResult(
            RecommendationResponse response,
            LocalDate priceDataDate,
            OffsetDateTime newsAnalyzedAt
    ) {
    }
}
