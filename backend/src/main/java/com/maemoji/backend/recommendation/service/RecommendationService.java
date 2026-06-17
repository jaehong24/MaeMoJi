package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.domain.NewsAnalysisCacheRecord;
import com.maemoji.backend.recommendation.domain.NewsAnalysisSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationEvidenceRecord;
import com.maemoji.backend.recommendation.domain.RecommendationEvidenceSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationFactorDetailRecord;
import com.maemoji.backend.recommendation.domain.RecommendationFactorDetailSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationRecord;
import com.maemoji.backend.recommendation.domain.RecommendationSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationTarget;
import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import com.maemoji.backend.recommendation.dto.RecommendationCalculationResponse;
import com.maemoji.backend.recommendation.dto.RecommendationEvidenceResponse;
import com.maemoji.backend.recommendation.dto.HomeRecommendationResponse;
import com.maemoji.backend.recommendation.dto.RecommendationResponse;
import com.maemoji.backend.recommendation.dto.RecommendationScoresResponse;
import com.maemoji.backend.recommendation.dto.RelatedNewsResponse;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.stock.domain.StockPriceSnapshotRecord;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

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

    private static final Logger log = LoggerFactory.getLogger(RecommendationService.class);
    private static final String ENGINE_VERSION = "RULE_V3_EXPLAINABLE_SCORE_V2";
    private static final ZoneId HOME_ZONE = ZoneId.of("Asia/Seoul");
    private static final int RECENT_NEWS_TRADING_DAY_WINDOW = 3;
    private static final int DISPLAY_NEWS_LIMIT = 3;
    private static final Set<String> LEGACY_V4_EVIDENCE_TYPES = Set.of(
            "PRICE",
            "NEWS",
            "EARNINGS",
            "INSTITUTION",
            "FORMULA"
    );
    private static final Set<String> HARD_RISK_KEYWORDS = Set.of(
            "fraud", "delist", "bankruptcy", "lawsuit", "investigation",
            "분식", "상장폐지", "파산", "소송", "회계부정", "조사"
    );

    private final RecommendationMapper recommendationMapper;
    private final ObjectMapper objectMapper;
    private final NewsSentimentService newsSentimentService;
    private final RecommendationScoreCalculator scoreCalculator;
    private final StockPriceSnapshotMapper stockPriceSnapshotMapper;
    private final StockPriceSnapshotBatchService stockPriceSnapshotBatchService;
    private final RecommendationTuningProperties tuningProperties;
    private final HttpClient httpClient;
    private final TransactionTemplate transactionTemplate;

    public RecommendationService(
            RecommendationMapper recommendationMapper,
            ObjectMapper objectMapper,
            NewsSentimentService newsSentimentService,
            RecommendationScoreCalculator scoreCalculator,
            StockPriceSnapshotMapper stockPriceSnapshotMapper,
            StockPriceSnapshotBatchService stockPriceSnapshotBatchService,
            RecommendationTuningProperties tuningProperties,
            PlatformTransactionManager transactionManager
    ) {
        this.recommendationMapper = recommendationMapper;
        this.objectMapper = objectMapper;
        this.newsSentimentService = newsSentimentService;
        this.scoreCalculator = scoreCalculator;
        this.stockPriceSnapshotMapper = stockPriceSnapshotMapper;
        this.stockPriceSnapshotBatchService = stockPriceSnapshotBatchService;
        this.tuningProperties = tuningProperties;
        this.transactionTemplate = new TransactionTemplate(transactionManager);
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Transactional
    public List<RecommendationResponse> generateLatestRecommendations(Long userId) {
        return generateLatestRecommendations(userId, Map.of());
    }

    @Transactional
    public List<RecommendationResponse> generateLatestRecommendationsFromCachedData(Long userId) {
        final LocalDate recommendationDate = LocalDate.now(HOME_ZONE);
        final List<RecommendationTarget> targets =
                recommendationMapper.findActiveRecommendationTargetsByUserId(userId);

        final List<RecommendationResponse> responses = new ArrayList<>();
        for (RecommendationTarget target : targets) {
            final EngineResult engineResult = evaluateTarget(
                    target,
                    null,
                    false,
                    false
            );
            final Long recommendationId = saveRecommendation(userId, target, recommendationDate, engineResult);
            responses.add(toResponse(target, recommendationId, engineResult));
        }

        return responses;
    }

    @Transactional
    public List<RecommendationResponse> generateLatestRecommendations(
            Long userId,
            Map<Long, NewsSentimentService.NewsSentimentResult> sharedNewsByStockId
    ) {
        // Render는 UTC로 실행되므로 한국 날짜를 명시적으로 사용합니다.
        final LocalDate recommendationDate = LocalDate.now(HOME_ZONE);
        final List<RecommendationTarget> targets =
                recommendationMapper.findActiveRecommendationTargetsByUserId(userId);

        final List<RecommendationResponse> responses = new ArrayList<>();
        for (RecommendationTarget target : targets) {
            final EngineResult engineResult = evaluateTarget(
                    target,
                    sharedNewsByStockId.get(target.getStockId())
            );
            final Long recommendationId = saveRecommendation(userId, target, recommendationDate, engineResult);
            responses.add(toResponse(target, recommendationId, engineResult));
        }

        return responses;
    }

    public SharedNewsAnalysisWarmupResult warmUpSharedNewsAnalysis() {
        final List<RecommendationTarget> distinctTargets =
                recommendationMapper.findDistinctActiveRecommendationTargets();
        final Map<Long, NewsSentimentService.NewsSentimentResult> sharedResults = new LinkedHashMap<>();
        int reusedCount = 0;
        int refreshedCount = 0;
        int unavailableCount = 0;

        for (RecommendationTarget target : distinctTargets) {
            final NewsSentimentService.NewsSentimentResult analyzed = newsSentimentService.analyze(
                    target.getStockId(),
                    resolveSymbol(target),
                    target.getCompanyName()
            );

            if (analyzed.relatedNews().isEmpty()) {
                unavailableCount++;
            } else if (analyzed.cacheReused()) {
                reusedCount++;
            } else {
                refreshedCount++;
            }

            if (analyzed.replaceCache()) {
                transactionTemplate.executeWithoutResult(status ->
                        replaceNewsAnalysisCache(
                                target.getStockId(),
                                analyzed.relatedNews(),
                                analyzed.llmModel()
                        )
                );
            }

            sharedResults.put(target.getStockId(), withoutCacheWrite(analyzed));
        }

        return new SharedNewsAnalysisWarmupResult(
                sharedResults,
                distinctTargets.size(),
                reusedCount,
                refreshedCount,
                unavailableCount
        );
    }

    public void warmUpLatestNewsForUserStock(Long userId, Long stockId) {
        final RecommendationTarget target =
                recommendationMapper.findActiveRecommendationTargetByUserIdAndStockId(userId, stockId);
        if (target == null) {
            return;
        }

        final NewsSentimentService.NewsSentimentResult analyzed = newsSentimentService.analyze(
                target.getStockId(),
                resolveSymbol(target),
                target.getCompanyName()
        );

        if (analyzed.replaceCache()) {
            transactionTemplate.executeWithoutResult(status ->
                    replaceNewsAnalysisCache(
                            target.getStockId(),
                            analyzed.relatedNews(),
                            analyzed.llmModel()
                    )
            );
        }

        log.info(
                "포트폴리오 저장 직후 뉴스 선분석을 완료했습니다. userId={}, stockId={}, articles={}, cacheReused={}",
                userId,
                stockId,
                analyzed.relatedNews().size(),
                analyzed.cacheReused()
        );
    }

    @Transactional
    public List<RecommendationResponse> getLatestRecommendations(Long userId) {
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
    public RecommendationResponse getRecommendationDetail(Long userId, Long portfolioItemId) {
        return getLatestRecommendations(userId).stream()
                .filter(item -> portfolioItemId.equals(item.portfolioItemId()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("추천 상세 대상을 찾을 수 없습니다."));
    }

    @Transactional
    public HomeRecommendationResponse getLightweightHomeRecommendations(Long userId) {
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
        final OffsetDateTime recommendationGeneratedAt = results.stream()
                .map(result -> result.response().recommendationGeneratedAt())
                .filter(generatedAt -> generatedAt != null)
                .max(OffsetDateTime::compareTo)
                .orElse(null);

        return new HomeRecommendationResponse(
                OffsetDateTime.now(HOME_ZONE),
                recommendationGeneratedAt,
                priceDataDate,
                newsAnalyzedAt,
                results.stream().map(LightweightRecommendationResult::response).toList()
        );
    }

    @Transactional
    public HomeRecommendationResponse getOptimizedHomeRecommendations(Long userId) {
        final List<RecommendationResponse> recommendations = getLatestRecommendations(userId);
        return buildHomeRecommendationResponse(recommendations);
    }

    @Transactional
    public RecommendationResponse getOptimizedRecommendationDetail(Long userId, Long portfolioItemId) {
        RecommendationRecord record = recommendationMapper
                .findLatestRecommendationByUserIdAndPortfolioItemId(userId, portfolioItemId);

        if (record == null) {
            final RecommendationTarget target = recommendationMapper
                    .findActiveRecommendationTargetByUserIdAndPortfolioItemId(userId, portfolioItemId);
            if (target != null) {
                return toPendingResponse(target);
            }
            throw new IllegalArgumentException("추천 상세 대상을 찾을 수 없습니다.");
        }

        if (shouldRebuildRecommendationForDetail(record)) {
            final RecommendationTarget target = recommendationMapper
                    .findActiveRecommendationTargetByUserIdAndPortfolioItemId(userId, portfolioItemId);
            if (target != null) {
                return rebuildRecommendationFromCachedData(userId, target);
            }
        }

        return toResponse(record);
    }

    public RecommendationResponse refreshRecommendationDetail(Long userId, Long portfolioItemId) {
        final RecommendationRecord existingRecord = recommendationMapper
                .findLatestRecommendationByUserIdAndPortfolioItemId(userId, portfolioItemId);
        if (existingRecord != null
                && isSameRecommendationDay(existingRecord.getRecommendationDate())
                && !shouldRebuildRecommendationForDetail(existingRecord)) {
            return toResponse(existingRecord);
        }

        final RecommendationTarget target = recommendationMapper
                .findActiveRecommendationTargetByUserIdAndPortfolioItemId(userId, portfolioItemId);
        if (target == null) {
            throw new IllegalArgumentException("추천 상세 대상을 찾을 수 없습니다.");
        }

        final LocalDate recommendationDate = LocalDate.now(HOME_ZONE);
        final EngineResult engineResult = evaluateTarget(target);
        final Long recommendationId = saveRecommendation(
                userId,
                target,
                recommendationDate,
                engineResult
        );
        return toResponse(target, recommendationId, engineResult);
    }

    private boolean shouldRebuildRecommendationForDetail(RecommendationRecord record) {
        if (record == null) {
            return false;
        }
        if (!isSameRecommendationDay(record.getRecommendationDate())) {
            return false;
        }
        return blankToEmpty(record.getRiskProfileApplied()).isBlank()
                || blankToEmpty(record.getFormulaVersion()).isBlank();
    }

    private RecommendationResponse rebuildRecommendationFromCachedData(
            Long userId,
            RecommendationTarget target
    ) {
        final LocalDate recommendationDate = LocalDate.now(HOME_ZONE);
        final EngineResult engineResult = evaluateTarget(
                target,
                null,
                false,
                false
        );
        final Long recommendationId = transactionTemplate.execute(status ->
                saveRecommendation(
                        userId,
                        target,
                        recommendationDate,
                        engineResult
                )
        );
        if (recommendationId == null) {
            throw new IllegalStateException("추천 결과를 저장하지 못했습니다.");
        }
        return toResponse(target, recommendationId, engineResult);
    }

    private EngineResult evaluateTarget(
            RecommendationTarget target,
            NewsSentimentService.NewsSentimentResult sharedNewsSentiment
    ) {
        return evaluateTarget(target, sharedNewsSentiment, true, true);
    }

    private EngineResult evaluateTarget(
            RecommendationTarget target,
            NewsSentimentService.NewsSentimentResult sharedNewsSentiment,
            boolean allowExternalNewsFetch,
            boolean allowExternalPriceFetch
    ) {
        final BigDecimal currentAmount = safeAmount(target.getDailyInvestAmount());
        final String memo = blankToEmpty(target.getMemo());
        final boolean hasHardRisk = containsHardRiskKeyword(memo);

        final PriceSnapshot priceSnapshot = fetchPriceSnapshot(target, allowExternalPriceFetch);
        final NewsSentimentService.NewsSentimentResult newsSentiment =
                resolveNewsSentiment(target, sharedNewsSentiment, allowExternalNewsFetch);

        final int confidenceScore = resolveConfidence(target, priceSnapshot, newsSentiment);
        final Integer rawNewsSentiment = newsSentiment.relatedNews().isEmpty()
                ? null
                : newsSentiment.weightedSentimentScore();
        final V4ScoringContext v4Context = buildV4ScoringContext(
                target,
                priceSnapshot,
                newsSentiment,
                confidenceScore,
                hasHardRisk
        );
        final RecommendationScoreCalculator.V4ScoreResult v4ScoreResult =
                scoreCalculator.calculateV4(v4Context.input());
        final RecommendationScoreCalculator.ScoreResult scoreResult =
                scoreCalculator.toLegacyScoreResult(
                        v4ScoreResult,
                        priceSnapshot.thirtyDayReturn(),
                        rawNewsSentiment
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
        final List<RecommendationEvidenceSaveCommand> evidence = buildV4Evidence(
                target,
                priceSnapshot,
                newsSentiment,
                v4Context,
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
                v4Context.fundamentalQualityScoreOrZero(),
                v4Context.priceStabilityScoreOrZero(),
                v4Context.priceMomentumScoreOrZero(),
                v4Context.newsScoreOrZero(),
                v4Context.userFitScoreOrZero(),
                evidence,
                newsSentiment.relatedNews(),
                newsSentiment.llmModel(),
                newsSentiment.analysisConfidence(),
                newsSentiment.cacheReused(),
                newsSentiment.replaceCache(),
                scoreResult,
                v4ScoreResult,
                v4Context
        );
    }

    private EngineResult evaluateTarget(RecommendationTarget target) {
        return evaluateTarget(target, null);
    }

    private NewsSentimentService.NewsSentimentResult resolveNewsSentiment(
            RecommendationTarget target,
            NewsSentimentService.NewsSentimentResult sharedNewsSentiment,
            boolean allowExternalNewsFetch
    ) {
        if (sharedNewsSentiment != null) {
            return sharedNewsSentiment;
        }

        final NewsSentimentService.NewsSentimentResult cachedResult =
                newsSentimentService.findCachedDisplayResult(target.getStockId());
        if (cachedResult != null) {
            return cachedResult;
        }

        if (!allowExternalNewsFetch) {
            return NewsSentimentService.NewsSentimentResult.unavailable();
        }

        return newsSentimentService.analyze(
                target.getStockId(),
                resolveSymbol(target),
                target.getCompanyName()
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
        command.setFormulaVersion(engineResult.scoreResult().formulaVersion());
        command.setRawScore(engineResult.scoreResult().rawScore());
        command.setRiskAdjustment(engineResult.scoreResult().riskAdjustment());
        command.setPriceScore(engineResult.scoreResult().priceScore());
        command.setNewsScore(engineResult.scoreResult().newsScore());
        command.setPriceWeight(engineResult.scoreResult().priceWeight());
        command.setNewsWeight(engineResult.scoreResult().newsWeight());
        command.setPriceReturn30d(decimalOrNull(engineResult.scoreResult().thirtyDayReturn()));
        command.setNewsSentimentScore(engineResult.scoreResult().newsSentimentScore());
        command.setPriceMomentumScore(engineResult.priceOverheatingScore());
        command.setPriceStabilityScore(engineResult.valuationScore());
        command.setFundamentalQualityScore(engineResult.businessHealthScore());
        command.setUserFitScore(engineResult.institutionalConfidenceScore());
        command.setCrossFactorAdjustment(resolveCrossFactorAdjustmentFromScoreResult(engineResult.scoreResult()));
        command.setUserAdjustment(engineResult.v4ScoreResult() == null ? 0 : engineResult.v4ScoreResult().userAdjustment());
        command.setRiskProfileApplied(
                engineResult.v4ScoreResult() == null
                        ? "BALANCED"
                        : engineResult.v4ScoreResult().effectiveRiskProfile()
        );
        command.setConfidenceBreakdownJson(buildConfidenceBreakdownJson(engineResult, target));
        command.setIncreaseEligible(engineResult.scoreResult().increaseEligible());

        final Long recommendationId = recommendationMapper.upsertRecommendation(command);
        command.setRecommendationId(recommendationId);
        recommendationMapper.deleteRecommendationEvidence(recommendationId);
        recommendationMapper.deleteRecommendationFactorDetails(recommendationId);
        for (RecommendationEvidenceSaveCommand evidenceCommand : engineResult.evidence()) {
            evidenceCommand.setRecommendationId(recommendationId);
            recommendationMapper.insertRecommendationEvidence(evidenceCommand);
        }
        for (RecommendationFactorDetailSaveCommand factorDetailCommand
                : buildRecommendationFactorDetails(engineResult.v4ScoreResult(), engineResult.v4Context())) {
            factorDetailCommand.setRecommendationId(recommendationId);
            recommendationMapper.insertRecommendationFactorDetail(factorDetailCommand);
        }

        if (engineResult.replaceNewsCache()) {
            replaceNewsAnalysisCache(target.getStockId(), engineResult.relatedNews(), engineResult.llmModel());
        }

        return recommendationId;
    }

    private void replaceNewsAnalysisCache(
            Long stockId,
            List<NewsSentimentService.AnalyzedNewsItem> relatedNews,
            String llmModel
    ) {
        recommendationMapper.deleteNewsAnalysisCacheByStockId(stockId);
        for (NewsSentimentService.AnalyzedNewsItem newsItem : relatedNews) {
            final NewsAnalysisSaveCommand newsCommand = new NewsAnalysisSaveCommand();
            newsCommand.setStockId(stockId);
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
            newsCommand.setLlmModel(llmModel);
            newsCommand.setAnalyzedAt(OffsetDateTime.now(ZoneOffset.UTC));
            recommendationMapper.insertNewsAnalysisCache(newsCommand);
        }
    }

    private NewsSentimentService.NewsSentimentResult withoutCacheWrite(
            NewsSentimentService.NewsSentimentResult source
    ) {
        return new NewsSentimentService.NewsSentimentResult(
                source.score(),
                source.label(),
                source.summary(),
                source.relatedNews(),
                source.llmModel(),
                source.weightedSentimentScore(),
                source.hardNegativeOverride(),
                source.analysisConfidence(),
                source.cacheReused(),
                false
        );
    }

    private LightweightRecommendationResult toLightweightHomeResponse(RecommendationTarget target) {
        final StockPriceSnapshotRecord snapshot =
                stockPriceSnapshotMapper.findLatestSnapshotByStockId(target.getStockId());
        final List<NewsAnalysisCacheRecord> cachedNews = selectDisplayNewsRecords(
                recommendationMapper.findLatestNewsAnalysisByStockId(target.getStockId())
        );
        final CachedNewsSummary newsSummary = summarizeCachedNews(cachedNews);
        final Double thirtyDayReturn = snapshot == null || snapshot.getChangeRate30d() == null
                ? null
                : snapshot.getChangeRate30d().doubleValue();
        final boolean hardStopRisk = (thirtyDayReturn != null && thirtyDayReturn <= -35)
                || containsHardRiskKeyword(blankToEmpty(target.getMemo()));
        final int confidence = resolveLightweightConfidence(target, snapshot, newsSummary);
        final PriceSnapshot lightweightPriceSnapshot = snapshot == null
                ? PriceSnapshot.unavailable()
                : new PriceSnapshot(
                        snapshot.getCurrentPrice() == null ? null : snapshot.getCurrentPrice().doubleValue(),
                        snapshot.getChangeRate7d() == null ? null : snapshot.getChangeRate7d().doubleValue(),
                        snapshot.getChangeRate30d() == null ? null : snapshot.getChangeRate30d().doubleValue(),
                        snapshot.getMarketCap(),
                        snapshot.getPerValue(),
                        snapshot.getEpsTtm(),
                        snapshot.getRevenueGrowthYoy(),
                        snapshot.getGrossMarginTtm(),
                        snapshot.getNetMarginTtm(),
                        snapshot.getOperatingMarginTtm(),
                        snapshot.getRoeTtm(),
                        snapshot.getRoaTtm(),
                        snapshot.getRoicTtm(),
                        snapshot.getDebtToEquityTtm(),
                        snapshot.getCurrentRatioTtm(),
                        snapshot.getQuickRatioTtm(),
                        snapshot.getAssetTurnoverTtm(),
                        snapshot.getFreeCashFlowYieldTtm(),
                        snapshot.getOperatingCashFlowRatioTtm(),
                        snapshot.getIncomeQualityTtm()
                );
        final NewsSentimentService.NewsSentimentResult lightweightNewsSentiment =
                buildLightweightNewsSentiment(newsSummary);
        final V4ScoringContext v4Context = buildV4ScoringContext(
                target,
                lightweightPriceSnapshot,
                lightweightNewsSentiment,
                confidence,
                containsHardRiskKeyword(blankToEmpty(target.getMemo()))
        );
        final RecommendationScoreCalculator.ScoreResult scoreResult = scoreCalculator.calculateV4Legacy(
                v4Context.input(),
                thirtyDayReturn,
                newsSummary.sentimentScore()
        );
        final BigDecimal currentAmount = safeAmount(target.getDailyInvestAmount());
        final BigDecimal recommendedAmount = resolveRecommendedAmount(
                currentAmount,
                scoreResult.recommendationStatus()
        );
        final List<RecommendationEvidenceResponse> evidence = buildLightweightEvidence(
                scoreResult,
                newsSummary,
                v4Context
        );
        final OffsetDateTime newsAnalyzedAt = cachedNews.stream()
                .map(NewsAnalysisCacheRecord::getAnalyzedAt)
                .filter(analyzedAt -> analyzedAt != null)
                .max(OffsetDateTime::compareTo)
                .orElse(null);

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
                null,
                null,
                newsAnalyzedAt,
                resolveRelatedNewsStatusMessage(
                        recommendationMapper.findLatestNewsAnalysisByStockId(target.getStockId()),
                        cachedNews
                ),
                new RecommendationScoresResponse(
                        v4Context.fundamentalQualityScoreOrZero(),
                        v4Context.priceStabilityScoreOrZero(),
                        v4Context.priceMomentumScoreOrZero(),
                        v4Context.newsScoreOrZero(),
                        v4Context.userFitScoreOrZero()
                ),
                toCalculationResponse(scoreResult),
                evidence,
                cachedNews.stream().map(this::toRelatedNewsResponse).toList()
        );
        return new LightweightRecommendationResult(
                response,
                snapshot == null ? null : snapshot.getSnapshotDate(),
                newsAnalyzedAt
        );
    }

    private LightweightRecommendationResult toLightweightHomeResponse(RecommendationResponse response) {
        final StockPriceSnapshotRecord snapshot =
                stockPriceSnapshotMapper.findLatestSnapshotByStockId(response.stockId());
        final List<NewsAnalysisCacheRecord> cachedNews = selectDisplayNewsRecords(
                recommendationMapper.findLatestNewsAnalysisByStockId(response.stockId())
        );
        final OffsetDateTime newsAnalyzedAt = cachedNews.stream()
                .map(NewsAnalysisCacheRecord::getAnalyzedAt)
                .filter(analyzedAt -> analyzedAt != null)
                .max(OffsetDateTime::compareTo)
                .orElse(null);
        return new LightweightRecommendationResult(
                response,
                snapshot == null ? null : snapshot.getSnapshotDate(),
                newsAnalyzedAt
        );
    }

    private HomeRecommendationResponse buildHomeRecommendationResponse(
            List<RecommendationResponse> recommendations
    ) {
        final List<LightweightRecommendationResult> results = recommendations.stream()
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
        final OffsetDateTime recommendationGeneratedAt = results.stream()
                .map(result -> result.response().recommendationGeneratedAt())
                .filter(generatedAt -> generatedAt != null)
                .max(OffsetDateTime::compareTo)
                .orElse(null);

        return new HomeRecommendationResponse(
                OffsetDateTime.now(HOME_ZONE),
                recommendationGeneratedAt,
                priceDataDate,
                newsAnalyzedAt,
                results.stream().map(LightweightRecommendationResult::response).toList()
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

    private List<NewsAnalysisCacheRecord> filterFreshNewsRecords(List<NewsAnalysisCacheRecord> records) {
        if (records == null || records.isEmpty()) {
            return List.of();
        }

        final LocalDate latestAllowedTradingDate = latestTradingDateOnOrBefore(LocalDate.now(HOME_ZONE));
        return records.stream()
                .filter(record -> isFreshNewsPublishedAt(record.getNewsPublishedAt(), latestAllowedTradingDate))
                .limit(DISPLAY_NEWS_LIMIT)
                .toList();
    }

    private List<NewsAnalysisCacheRecord> selectDisplayNewsRecords(List<NewsAnalysisCacheRecord> records) {
        if (records == null || records.isEmpty()) {
            return List.of();
        }

        final List<NewsAnalysisCacheRecord> freshRecords = filterFreshNewsRecords(records);
        if (!freshRecords.isEmpty()) {
            return freshRecords;
        }

        return records.stream()
                .limit(DISPLAY_NEWS_LIMIT)
                .toList();
    }

    private String resolveRelatedNewsStatusMessage(
            List<NewsAnalysisCacheRecord> rawNewsRecords,
            List<NewsAnalysisCacheRecord> displayNewsRecords
    ) {
        if (displayNewsRecords != null && !displayNewsRecords.isEmpty()) {
            if (rawNewsRecords != null
                    && !rawNewsRecords.isEmpty()
                    && !filterFreshNewsRecords(rawNewsRecords).isEmpty()) {
                return null;
            }
            return "최근 3거래일 관련 뉴스가 없어 가장 최근 분석을 먼저 보여드려요.";
        }
        if (rawNewsRecords == null || rawNewsRecords.isEmpty()) {
            return "관련 뉴스가 아직 없습니다.";
        }
        return "최근 관련 뉴스가 부족해 표시 가능한 최신 분석이 아직 없습니다.";
    }

    private boolean isFreshNewsPublishedAt(OffsetDateTime publishedAt, LocalDate latestAllowedTradingDate) {
        if (publishedAt == null || latestAllowedTradingDate == null) {
            return false;
        }

        final LocalDate publishedDate = publishedAt.atZoneSameInstant(HOME_ZONE).toLocalDate();
        return tradingDayGap(publishedDate, latestAllowedTradingDate)
                <= RECENT_NEWS_TRADING_DAY_WINDOW;
    }

    private LocalDate latestTradingDateOnOrBefore(LocalDate date) {
        LocalDate cursor = date;
        while (isWeekend(cursor)) {
            cursor = cursor.minusDays(1);
        }
        return cursor;
    }

    private int tradingDayGap(LocalDate olderDate, LocalDate newerDate) {
        if (olderDate == null || newerDate == null || olderDate.isAfter(newerDate)) {
            return Integer.MAX_VALUE;
        }

        int gap = 0;
        LocalDate cursor = olderDate.plusDays(1);
        while (!cursor.isAfter(newerDate)) {
            if (!isWeekend(cursor)) {
                gap++;
            }
            cursor = cursor.plusDays(1);
        }
        return gap;
    }

    private boolean isWeekend(LocalDate date) {
        return switch (date.getDayOfWeek()) {
            case SATURDAY, SUNDAY -> true;
            default -> false;
        };
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
                1,
                null
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
                2,
                null
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

    private List<RecommendationEvidenceResponse> buildLightweightEvidence(
            RecommendationScoreCalculator.ScoreResult scoreResult,
            CachedNewsSummary newsSummary,
            V4ScoringContext v4Context
    ) {
        final List<RecommendationEvidenceResponse> evidence = new ArrayList<>();
        evidence.add(new RecommendationEvidenceResponse(
                "PRICE_MOMENTUM",
                "가격 흐름",
                scoreResult.thirtyDayReturn() == null
                        ? "아직 30일 가격 데이터가 충분하지 않아 가격 흐름 평가는 보수적으로 반영했어요."
                        : "최근 30일 수익률 "
                        + formatSignedPercent(scoreResult.thirtyDayReturn())
                        + "와 가격 안정성을 함께 반영했어요.",
                v4Context.priceMomentumScore(),
                1,
                null
        ));
        evidence.add(new RecommendationEvidenceResponse(
                "NEWS_CACHE",
                "뉴스 분석",
                newsSummary.sentimentScore() == null
                        ? "최근 저장된 관련 뉴스 분석이 아직 없어 뉴스 점수는 제외했어요."
                        : "최근 저장된 뉴스 감성 점수 "
                        + formatSignedNumber(newsSummary.sentimentScore())
                        + "를 추천에 반영했어요.",
                v4Context.newsScore(),
                2,
                null
        ));
        if (v4Context.userFitScore() != null) {
            evidence.add(new RecommendationEvidenceResponse(
                    "USER_FIT",
                    "내 투자 상황",
                    "현재 매일 모으기 금액과 보유 정보를 함께 반영했어요.",
                    v4Context.userFitScore(),
                    3,
                    null
            ));
        }
        return evidence;
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
                LocalDate.now(HOME_ZONE),
                OffsetDateTime.now(ZoneOffset.UTC),
                engineResult.relatedNews().isEmpty() ? null : OffsetDateTime.now(ZoneOffset.UTC),
                engineResult.relatedNews().isEmpty() ? "최근 3거래일 관련 뉴스가 아직 없습니다." : null,
                new RecommendationScoresResponse(
                        engineResult.businessHealthScore(),
                        engineResult.valuationScore(),
                        engineResult.priceOverheatingScore(),
                        engineResult.newsSentimentScore(),
                        engineResult.institutionalConfidenceScore()
                ),
                toCalculationResponse(engineResult, target),
                buildGeneratedEvidenceResponses(engineResult),
                engineResult.relatedNews().stream()
                        .map(this::toRelatedNewsResponse)
                        .toList()
        );
    }

    private RecommendationResponse toResponse(RecommendationRecord record) {
        final List<RecommendationEvidenceRecord> evidenceRecords =
                recommendationMapper.findRecommendationEvidenceByRecommendationId(record.getRecommendationId());
        final List<RecommendationFactorDetailRecord> factorDetailRecords =
                recommendationMapper.findRecommendationFactorDetailsByRecommendationId(record.getRecommendationId());
        final List<NewsAnalysisCacheRecord> rawNewsRecords =
                recommendationMapper.findLatestNewsAnalysisByStockId(record.getStockId());
        final List<NewsAnalysisCacheRecord> newsRecords = selectDisplayNewsRecords(rawNewsRecords);
        final OffsetDateTime newsAnalyzedAt = rawNewsRecords.stream()
                .map(NewsAnalysisCacheRecord::getAnalyzedAt)
                .filter(analyzedAt -> analyzedAt != null)
                .max(OffsetDateTime::compareTo)
                .orElse(null);

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
                record.getRecommendationDate(),
                record.getCreatedAt(),
                newsAnalyzedAt,
                resolveRelatedNewsStatusMessage(rawNewsRecords, newsRecords),
                extractScores(record, evidenceRecords),
                toCalculationResponse(record),
                mergeEvidenceResponses(record, factorDetailRecords, evidenceRecords),
                newsRecords.stream()
                        .map(this::toRelatedNewsResponse)
                        .toList()
        );
    }

    private RecommendationResponse toPendingResponse(RecommendationTarget target) {
        final List<NewsAnalysisCacheRecord> rawNewsRecords =
                recommendationMapper.findLatestNewsAnalysisByStockId(target.getStockId());
        final List<NewsAnalysisCacheRecord> newsRecords = selectDisplayNewsRecords(rawNewsRecords);
        final OffsetDateTime newsAnalyzedAt = rawNewsRecords.stream()
                .map(NewsAnalysisCacheRecord::getAnalyzedAt)
                .filter(analyzedAt -> analyzedAt != null)
                .max(OffsetDateTime::compareTo)
                .orElse(null);
        final BigDecimal currentAmount = safeAmount(target.getDailyInvestAmount());
        final List<RecommendationEvidenceResponse> evidence = List.of(
                new RecommendationEvidenceResponse(
                        "PENDING",
                        "추천 분석 대기",
                        "홈 화면에서는 저장된 추천 결과만 빠르게 보여줍니다. 상세 분석이 필요하면 추천 생성 시 최신 분석을 불러옵니다.",
                        null,
                        1,
                        null
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
                null,
                null,
                newsAnalyzedAt,
                "관련 뉴스 분석을 아직 준비 중입니다.",
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
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        false
                ),
                evidence,
                newsRecords.stream()
                        .map(this::toRelatedNewsResponse)
                        .toList()
        );
    }

    private RecommendationScoresResponse extractScores(
            RecommendationRecord record,
            List<RecommendationEvidenceRecord> evidenceRecords
    ) {
        if (blankToEmpty(record.getFormulaVersion()).startsWith("SCORE_V4")) {
            return new RecommendationScoresResponse(
                    zeroIfNull(record.getFundamentalQualityScore()),
                    zeroIfNull(record.getPriceStabilityScore()),
                    zeroIfNull(record.getPriceMomentumScore()),
                    zeroIfNull(record.getNewsScore()),
                    zeroIfNull(record.getUserFitScore())
            );
        }

        final Map<String, Integer> scoreMap = evidenceRecords.stream()
                .filter(evidenceRecord -> evidenceRecord.getScoreImpact() != null)
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
                command.getDisplayOrder(),
                null
        );
    }

    private RecommendationEvidenceResponse toEvidenceResponse(RecommendationEvidenceRecord record) {
        return new RecommendationEvidenceResponse(
                record.getEvidenceType(),
                record.getTitle(),
                record.getBody(),
                record.getScoreImpact(),
                record.getDisplayOrder(),
                null
        );
    }

    private List<RecommendationEvidenceResponse> mergeEvidenceResponses(
            RecommendationRecord record,
            List<RecommendationFactorDetailRecord> factorDetailRecords,
            List<RecommendationEvidenceRecord> evidenceRecords
    ) {
        if (!blankToEmpty(record.getFormulaVersion()).startsWith("SCORE_V4")) {
            return evidenceRecords.stream()
                    .map(this::toEvidenceResponse)
                    .toList();
        }

        final LinkedHashMap<String, RecommendationEvidenceResponse> deduplicated = new LinkedHashMap<>();
        factorDetailRecords.stream()
                .map(this::toEvidenceResponse)
                .forEach(response -> deduplicated.putIfAbsent(response.evidenceType(), response));
        evidenceRecords.stream()
                .filter(evidenceRecord -> !LEGACY_V4_EVIDENCE_TYPES.contains(
                        blankToEmpty(evidenceRecord.getEvidenceType())
                ))
                .map(this::toEvidenceResponse)
                .forEach(response -> deduplicated.putIfAbsent(response.evidenceType(), response));
        return new ArrayList<>(deduplicated.values());
    }

    private List<RecommendationEvidenceResponse> buildGeneratedEvidenceResponses(
            EngineResult engineResult
    ) {
        if (!blankToEmpty(engineResult.scoreResult().formulaVersion()).startsWith("SCORE_V4")) {
            return engineResult.evidence().stream()
                    .map(this::toEvidenceResponse)
                    .toList();
        }

        final List<RecommendationEvidenceResponse> responses = new ArrayList<>();
        responses.addAll(
                buildRecommendationFactorDetails(engineResult.v4ScoreResult(), engineResult.v4Context()).stream()
                        .map(this::toEvidenceResponse)
                        .toList()
        );
        responses.addAll(
                engineResult.evidence().stream()
                        .filter(evidenceCommand -> !LEGACY_V4_EVIDENCE_TYPES.contains(
                                blankToEmpty(evidenceCommand.getEvidenceType())
                        ))
                        .map(this::toEvidenceResponse)
                        .toList()
        );
        return responses;
    }

    private RecommendationEvidenceResponse toEvidenceResponse(RecommendationFactorDetailRecord record) {
        return new RecommendationEvidenceResponse(
                "FACTOR_" + blankToEmpty(record.getFactorCode()),
                resolveFactorTitle(record.getFactorCode()),
                buildFactorEvidenceBody(
                        record.getFactorCode(),
                        record.getFactorSummary(),
                        record.getFactorScore(),
                        record.getFactorWeight(),
                        record.getFactorRawJson()
                ),
                record.getFactorScore(),
                resolveFactorDisplayOrder(record.getFactorCode()),
                record.getFactorRawJson()
        );
    }

    private RecommendationEvidenceResponse toEvidenceResponse(
            RecommendationFactorDetailSaveCommand command
    ) {
        return new RecommendationEvidenceResponse(
                "FACTOR_" + blankToEmpty(command.getFactorCode()),
                resolveFactorTitle(command.getFactorCode()),
                buildFactorEvidenceBody(
                        command.getFactorCode(),
                        command.getFactorSummary(),
                        command.getFactorScore(),
                        command.getFactorWeight(),
                        command.getFactorRawJson()
                ),
                command.getFactorScore(),
                resolveFactorDisplayOrder(command.getFactorCode()),
                command.getFactorRawJson()
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
                result.formulaVersion(),
                result.rawScore(),
                result.finalScore(),
                result.riskAdjustment(),
                result.priceScore(),
                result.newsScore(),
                result.priceWeight(),
                result.newsWeight(),
                result.thirtyDayReturn(),
                result.newsSentimentScore(),
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                result.increaseEligible()
        );
    }

    private RecommendationCalculationResponse toCalculationResponse(
            EngineResult engineResult,
            RecommendationTarget target
    ) {
        final RecommendationScoreCalculator.ScoreResult scoreResult = engineResult.scoreResult();
        final RecommendationScoreCalculator.V4ScoreResult v4ScoreResult = engineResult.v4ScoreResult();
        return new RecommendationCalculationResponse(
                scoreResult.formulaVersion(),
                scoreResult.rawScore(),
                scoreResult.finalScore(),
                scoreResult.riskAdjustment(),
                scoreResult.priceScore(),
                scoreResult.newsScore(),
                scoreResult.priceWeight(),
                scoreResult.newsWeight(),
                scoreResult.thirtyDayReturn(),
                scoreResult.newsSentimentScore(),
                engineResult.priceOverheatingScore(),
                engineResult.valuationScore(),
                engineResult.businessHealthScore(),
                engineResult.institutionalConfidenceScore(),
                v4ScoreResult == null ? null : v4ScoreResult.crossFactorAdjustment(),
                v4ScoreResult == null ? null : v4ScoreResult.userAdjustment(),
                v4ScoreResult == null ? null : v4ScoreResult.effectiveRiskProfile(),
                buildConfidenceBreakdownJson(engineResult, target),
                scoreResult.increaseEligible()
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
                record.getPriceMomentumScore(),
                record.getPriceStabilityScore(),
                record.getFundamentalQualityScore(),
                record.getUserFitScore(),
                record.getCrossFactorAdjustment(),
                record.getUserAdjustment(),
                blankToEmpty(record.getRiskProfileApplied()),
                blankToEmpty(record.getConfidenceBreakdownJson()),
                Boolean.TRUE.equals(record.getIncreaseEligible())
        );
    }

    private List<RecommendationEvidenceSaveCommand> buildV4Evidence(
            RecommendationTarget target,
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment,
            V4ScoringContext v4Context,
            RecommendationScoreCalculator.ScoreResult scoreResult,
            int priceContribution,
            int newsContribution
    ) {
        final List<RecommendationEvidenceSaveCommand> evidence = new ArrayList<>();
        evidence.add(evidence(
                "PRICE",
                "가격 흐름",
                priceSnapshot.hasThirtyDayReturn()
                        ? "최근 30일 수익률 "
                                + formatSignedPercent(priceSnapshot.thirtyDayReturn())
                                + ", 가격 흐름 점수 "
                                + safeScoreText(v4Context.priceMomentumScore())
                                + ", 안정성 점수 "
                                + safeScoreText(v4Context.priceStabilityScore())
                                + "를 함께 반영했어요."
                        : "가격 데이터가 충분하지 않아 가격 흐름 평가는 보수적으로 반영했어요.",
                scoreResult.priceScore() == null ? null : priceContribution,
                1
        ));
        evidence.add(evidence(
                "NEWS",
                "관련 뉴스 분석",
                scoreResult.newsScore() == null
                        ? "관련성 높은 최신 뉴스가 부족해 뉴스 점수는 이번 추천에서 제외했어요."
                        : newsSentiment.summary()
                                + " 종합 뉴스 점수 "
                                + safeScoreText(v4Context.newsScore())
                                + "를 반영했어요.",
                scoreResult.newsScore() == null ? null : newsContribution,
                2
        ));
        if (v4Context.fundamentalQualityScore() != null) {
            evidence.add(evidence(
                    "EARNINGS",
                    "기업 체력",
                    v4Context.fundamentalQualityAssessment() != null
                            ? v4Context.fundamentalQualityAssessment().summary()
                                    + " 기업 체력 점수 "
                                    + safeScoreText(v4Context.fundamentalQualityScore())
                                    + "점을 반영했어요."
                            : "시총과 밸류에이션 기반의 1차 기초체력 점수 "
                                    + safeScoreText(v4Context.fundamentalQualityScore())
                                    + "를 함께 반영했어요.",
                    v4Context.fundamentalQualityScore(),
                    3
            ));
        }
        if (v4Context.userFitScore() != null) {
            evidence.add(evidence(
                    "INSTITUTION",
                    "내 투자 상황",
                    "현재 매일 모으기 금액과 보유 상황을 반영한 적합도 점수 "
                            + safeScoreText(v4Context.userFitScore())
                            + "를 적용했어요.",
                    v4Context.userFitScore(),
                    4
            ));
        }
        evidence.add(evidence(
                "FORMULA",
                "최종 점수 계산",
                "V4 멀티 팩터 모델로 계산했어요. 원점수 "
                        + scoreResult.rawScore()
                        + "점에 위험 조정 "
                        + formatSignedNumber(scoreResult.riskAdjustment())
                        + "점을 반영해 최종 "
                        + scoreResult.finalScore()
                        + "점이 되었어요.",
                scoreResult.riskAdjustment(),
                5
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
                6
        ));
        return evidence;
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

    private List<RecommendationFactorDetailSaveCommand> buildRecommendationFactorDetails(
            RecommendationScoreCalculator.V4ScoreResult v4ScoreResult,
            V4ScoringContext v4Context
    ) {
        if (v4ScoreResult == null || v4ScoreResult.factors() == null) {
            return List.of();
        }

        final LinkedHashMap<String, RecommendationFactorDetailSaveCommand> commandsByFactor = new LinkedHashMap<>();
        for (RecommendationScoreCalculator.FactorResult factor : v4ScoreResult.factors()) {
            final RecommendationFactorDetailSaveCommand command =
                    new RecommendationFactorDetailSaveCommand();
            final String factorSummary = resolveFactorSummary(factor, v4Context);
            command.setFactorCode(factor.factorCode().name());
            command.setFactorScore(factor.score());
            command.setFactorWeight(factor.appliedWeight());
            command.setFactorSummary(factorSummary);
            command.setFactorRawJson(buildFactorRawJson(factor, v4ScoreResult, v4Context));
            commandsByFactor.put(command.getFactorCode(), command);
        }
        return new ArrayList<>(commandsByFactor.values());
    }

    private String resolveFactorSummary(
            RecommendationScoreCalculator.FactorResult factor,
            V4ScoringContext v4Context
    ) {
        return switch (factor.factorCode()) {
            case PRICE_MOMENTUM -> buildPriceMomentumSummary(
                    v4Context == null ? null : v4Context.priceSnapshot()
            );
            case PRICE_STABILITY -> buildPriceStabilitySummary(
                    v4Context == null ? null : v4Context.priceSnapshot()
            );
            case NEWS_SENTIMENT -> buildNewsSentimentSummary(
                    v4Context == null ? null : v4Context.rawNewsSentimentScore(),
                    v4Context == null ? null : v4Context.input()
            );
            case FUNDAMENTAL_QUALITY -> buildFundamentalFactorSummary(
                    v4Context == null ? null : v4Context.fundamentalQualityAssessment()
            );
            case VALUATION -> buildValuationFactorSummary(
                    v4Context == null ? null : v4Context.fundamentalQualityAssessment()
            );
            case QUALITY_OF_GROWTH -> buildQualityOfGrowthFactorSummary(
                    v4Context == null ? null : v4Context.fundamentalQualityAssessment()
            );
            case USER_FIT -> v4Context != null && v4Context.userFitAssessment() != null
                    ? blankToEmpty(v4Context.userFitAssessment().summary())
                    : factor.summary();
        };
    }

    private String buildFactorRawJson(
            RecommendationScoreCalculator.FactorResult factor,
            RecommendationScoreCalculator.V4ScoreResult v4ScoreResult,
            V4ScoringContext v4Context
    ) {
        try {
            final var node = objectMapper.createObjectNode();
            node.put("factorCode", factor.factorCode().name());
            node.put("score", factor.score());
            node.put("weight", factor.appliedWeight());
            node.put("summary", factor.summary());
            node.put("formulaVersion", v4ScoreResult.formulaVersion());
            node.put("finalScore", v4ScoreResult.finalScore());
            switch (factor.factorCode()) {
                case PRICE_MOMENTUM -> {
                    node.put("scoreKind", "PRICE_MOMENTUM_V1");
                    if (v4Context != null && v4Context.priceSnapshot() != null) {
                        putNullable(node, "changeRate7d", v4Context.priceSnapshot().changeRate7d());
                        putNullable(node, "changeRate30d", v4Context.priceSnapshot().thirtyDayReturn());
                    }
                }
                case PRICE_STABILITY -> {
                    node.put("scoreKind", "PRICE_STABILITY_V1");
                    if (v4Context != null && v4Context.priceSnapshot() != null) {
                        putNullable(node, "absChangeRate7d",
                                absoluteOrNull(v4Context.priceSnapshot().changeRate7d()));
                        putNullable(node, "absChangeRate30d",
                                absoluteOrNull(v4Context.priceSnapshot().thirtyDayReturn()));
                        node.put("hasSevereDrop", v4Context.priceSnapshot().hasSevereDrop());
                    }
                }
                case NEWS_SENTIMENT -> {
                    node.put("scoreKind", "NEWS_SENTIMENT_V1");
                    if (v4Context != null) {
                        putNullable(node, "weightedSentimentScore", v4Context.rawNewsSentimentScore());
                        node.put("hasNews", v4Context.rawNewsSentimentScore() != null);
                    }
                }
                case FUNDAMENTAL_QUALITY -> {
                    node.put("scoreKind", "FUNDAMENTAL_QUALITY_V2");
                    appendFundamentalQualityJson(
                            node,
                            v4Context == null ? null : v4Context.fundamentalQualityAssessment()
                    );
                }
                case VALUATION -> {
                    node.put("scoreKind", "VALUATION_V1");
                    appendFundamentalQualityJson(
                            node,
                            v4Context == null ? null : v4Context.fundamentalQualityAssessment()
                    );
                    putNullable(node, "valuationScore",
                            v4Context == null ? null : v4Context.valuationScore());
                }
                case QUALITY_OF_GROWTH -> {
                    node.put("scoreKind", "QUALITY_OF_GROWTH_V1");
                    appendFundamentalQualityJson(
                            node,
                            v4Context == null ? null : v4Context.fundamentalQualityAssessment()
                    );
                    putNullable(node, "qualityOfGrowthScore",
                            v4Context == null ? null : v4Context.qualityOfGrowthScore());
                }
                case USER_FIT -> {
                    node.put("scoreKind", "USER_FIT_V1");
                    if (v4Context != null && v4Context.target() != null) {
                        putNullable(
                                node,
                                "dailyInvestAmountUsd",
                                safeAmount(v4Context.target().getDailyInvestAmount()).doubleValue()
                        );
                        putNullable(
                                node,
                                "holdingQuantity",
                                v4Context.target().getHoldingQuantity() == null
                                        ? null
                                        : v4Context.target().getHoldingQuantity().doubleValue()
                        );
                        node.put("hasInvestmentStartDate", v4Context.target().getInvestmentStartDate() != null);
                        node.put("hasMemo", !blankToEmpty(v4Context.target().getMemo()).isBlank());
                    }
                    if (v4Context != null && v4Context.userFitAssessment() != null) {
                        final UserFitAssessment assessment = v4Context.userFitAssessment();
                        node.put("effectiveRiskProfile", assessment.effectiveRiskProfile());
                        node.put("riskProfileLabel", resolveRiskProfileDisplayName(assessment.effectiveRiskProfile()));
                        node.put("investmentDnaType", assessment.investmentDnaType());
                        putNullable(node, "daysHeld", assessment.daysHeld());
                        putNullable(node, "dailyInvestScoreAdjustment", assessment.dailyInvestScoreAdjustment());
                        putNullable(node, "holdingScoreAdjustment", assessment.holdingScoreAdjustment());
                        putNullable(node, "investmentStartScoreAdjustment", assessment.investmentStartScoreAdjustment());
                        putNullable(node, "memoScoreAdjustment", assessment.memoScoreAdjustment());
                        putNullable(node, "riskProfileAdjustment", assessment.riskProfileAdjustment());
                        putNullable(node, "budgetPressureAdjustment", assessment.budgetPressureAdjustment());
                        putNullable(node, "severeDropAdjustment", assessment.severeDropAdjustment());
                        putNullable(node, "finalUserAdjustment", assessment.finalUserAdjustment());
                        node.put("userFitSummary", assessment.summary());
                    }
                }
                default -> {
                }
            }
            return objectMapper.writeValueAsString(node);
        } catch (Exception exception) {
            return "{\"factorCode\":\"" + factor.factorCode().name() + "\"}";
        }
    }

    private void appendFundamentalQualityJson(
            com.fasterxml.jackson.databind.node.ObjectNode node,
            FundamentalQualityAssessment assessment
    ) {
        if (assessment == null) {
            return;
        }
        putNullable(node, "marketCapUsdMillion",
                assessment.marketCap() == null ? null : assessment.marketCap().doubleValue());
        putNullable(node, "perValue",
                assessment.perValue() == null ? null : assessment.perValue().doubleValue());
        putNullable(node, "epsTtm",
                assessment.epsTtm() == null ? null : assessment.epsTtm().doubleValue());
        putNullable(node, "revenueGrowthYoy",
                assessment.revenueGrowthYoy() == null ? null : assessment.revenueGrowthYoy().doubleValue());
        putNullable(node, "grossMarginTtm",
                assessment.grossMarginTtm() == null ? null : assessment.grossMarginTtm().doubleValue());
        putNullable(node, "netMarginTtm",
                assessment.netMarginTtm() == null ? null : assessment.netMarginTtm().doubleValue());
        putNullable(node, "operatingMarginTtm",
                assessment.operatingMarginTtm() == null ? null : assessment.operatingMarginTtm().doubleValue());
        putNullable(node, "roeTtm",
                assessment.roeTtm() == null ? null : assessment.roeTtm().doubleValue());
        putNullable(node, "roaTtm",
                assessment.roaTtm() == null ? null : assessment.roaTtm().doubleValue());
        putNullable(node, "roicTtm",
                assessment.roicTtm() == null ? null : assessment.roicTtm().doubleValue());
        putNullable(node, "debtToEquityTtm",
                assessment.debtToEquityTtm() == null ? null : assessment.debtToEquityTtm().doubleValue());
        putNullable(node, "currentRatioTtm",
                assessment.currentRatioTtm() == null ? null : assessment.currentRatioTtm().doubleValue());
        putNullable(node, "quickRatioTtm",
                assessment.quickRatioTtm() == null ? null : assessment.quickRatioTtm().doubleValue());
        putNullable(node, "assetTurnoverTtm",
                assessment.assetTurnoverTtm() == null ? null : assessment.assetTurnoverTtm().doubleValue());
        putNullable(node, "freeCashFlowYieldTtm",
                assessment.freeCashFlowYieldTtm() == null ? null : assessment.freeCashFlowYieldTtm().doubleValue());
        putNullable(node, "operatingCashFlowRatioTtm",
                assessment.operatingCashFlowRatioTtm() == null ? null : assessment.operatingCashFlowRatioTtm().doubleValue());
        putNullable(node, "incomeQualityTtm",
                assessment.incomeQualityTtm() == null ? null : assessment.incomeQualityTtm().doubleValue());
        putNullable(node, "marketCapAdjustment", assessment.marketCapAdjustment());
        putNullable(node, "perAdjustment", assessment.perAdjustment());
        putNullable(node, "epsAdjustment", assessment.epsAdjustment());
        putNullable(node, "revenueGrowthAdjustment", assessment.revenueGrowthAdjustment());
        putNullable(node, "grossMarginAdjustment", assessment.grossMarginAdjustment());
        putNullable(node, "netMarginAdjustment", assessment.netMarginAdjustment());
        putNullable(node, "operatingMarginAdjustment", assessment.operatingMarginAdjustment());
        putNullable(node, "roeAdjustment", assessment.roeAdjustment());
        putNullable(node, "roaAdjustment", assessment.roaAdjustment());
        putNullable(node, "roicAdjustment", assessment.roicAdjustment());
        putNullable(node, "debtToEquityAdjustment", assessment.debtToEquityAdjustment());
        putNullable(node, "currentRatioAdjustment", assessment.currentRatioAdjustment());
        putNullable(node, "quickRatioAdjustment", assessment.quickRatioAdjustment());
        putNullable(node, "assetTurnoverAdjustment", assessment.assetTurnoverAdjustment());
        putNullable(node, "freeCashFlowYieldAdjustment", assessment.freeCashFlowYieldAdjustment());
        putNullable(node, "operatingCashFlowRatioAdjustment", assessment.operatingCashFlowRatioAdjustment());
        putNullable(node, "incomeQualityAdjustment", assessment.incomeQualityAdjustment());
        putNullable(node, "combinationAdjustment", assessment.combinationAdjustment());
        putNullable(node, "scaleScore", assessment.scaleScore());
        putNullable(node, "valuationScore", assessment.valuationScore());
        putNullable(node, "growthScore", assessment.growthScore());
        putNullable(node, "profitabilityScore", assessment.profitabilityScore());
        putNullable(node, "safetyScore", assessment.safetyScore());
        putNullable(node, "cashFlowScore", assessment.cashFlowScore());
        putNullable(node, "efficiencyScore", assessment.efficiencyScore());
        if (assessment.marketCapTier() != null) {
            node.put("marketCapTier", assessment.marketCapTier());
        }
        if (assessment.perBand() != null) {
            node.put("perBand", assessment.perBand());
        }
        if (assessment.epsBand() != null) {
            node.put("epsBand", assessment.epsBand());
        }
        if (assessment.revenueGrowthBand() != null) {
            node.put("revenueGrowthBand", assessment.revenueGrowthBand());
        }
        if (assessment.grossMarginBand() != null) {
            node.put("grossMarginBand", assessment.grossMarginBand());
        }
        if (assessment.netMarginBand() != null) {
            node.put("netMarginBand", assessment.netMarginBand());
        }
        if (assessment.operatingMarginBand() != null) {
            node.put("operatingMarginBand", assessment.operatingMarginBand());
        }
        if (assessment.roeBand() != null) {
            node.put("roeBand", assessment.roeBand());
        }
        if (assessment.roaBand() != null) {
            node.put("roaBand", assessment.roaBand());
        }
        if (assessment.roicBand() != null) {
            node.put("roicBand", assessment.roicBand());
        }
        if (assessment.debtToEquityBand() != null) {
            node.put("debtToEquityBand", assessment.debtToEquityBand());
        }
        if (assessment.currentRatioBand() != null) {
            node.put("currentRatioBand", assessment.currentRatioBand());
        }
        if (assessment.quickRatioBand() != null) {
            node.put("quickRatioBand", assessment.quickRatioBand());
        }
        if (assessment.assetTurnoverBand() != null) {
            node.put("assetTurnoverBand", assessment.assetTurnoverBand());
        }
        if (assessment.freeCashFlowYieldBand() != null) {
            node.put("freeCashFlowYieldBand", assessment.freeCashFlowYieldBand());
        }
        if (assessment.operatingCashFlowRatioBand() != null) {
            node.put("operatingCashFlowRatioBand", assessment.operatingCashFlowRatioBand());
        }
        if (assessment.incomeQualityBand() != null) {
            node.put("incomeQualityBand", assessment.incomeQualityBand());
        }
    }

    private void putNullable(
            com.fasterxml.jackson.databind.node.ObjectNode node,
            String fieldName,
            Double value
    ) {
        if (value == null) {
            node.putNull(fieldName);
            return;
        }
        node.put(fieldName, value);
    }

    private void putNullable(
            com.fasterxml.jackson.databind.node.ObjectNode node,
            String fieldName,
            Integer value
    ) {
        if (value == null) {
            node.putNull(fieldName);
            return;
        }
        node.put(fieldName, value);
    }

    private Double absoluteOrNull(Double value) {
        return value == null ? null : Math.abs(value);
    }

    private Integer averageScores(Integer... scores) {
        int sum = 0;
        int count = 0;
        for (Integer score : scores) {
            if (score == null) {
                continue;
            }
            sum += score;
            count++;
        }
        if (count == 0) {
            return null;
        }
        return (int) Math.round(sum / (double) count);
    }

    private int clampScore(int score) {
        return Math.max(0, Math.min(score, 100));
    }

    private int interpolatePiecewise(double value, double[] breakpoints, int[] scores) {
        if (breakpoints.length != scores.length || breakpoints.length == 0) {
            throw new IllegalArgumentException("breakpoints and scores must have same non-zero length");
        }
        if (value <= breakpoints[0]) {
            return scores[0];
        }
        for (int index = 0; index < breakpoints.length - 1; index++) {
            final double left = breakpoints[index];
            final double right = breakpoints[index + 1];
            final int leftScore = scores[index];
            final int rightScore = scores[index + 1];
            if (value <= right) {
                if (Double.compare(left, right) == 0) {
                    return clampScore(rightScore);
                }
                final double ratio = (value - left) / (right - left);
                return clampScore((int) Math.round(leftScore + ((rightScore - leftScore) * ratio)));
            }
        }
        return clampScore(scores[scores.length - 1]);
    }

    private int weightedAverageScores(Object... valuesAndWeights) {
        double weightedSum = 0;
        int totalWeight = 0;
        for (int index = 0; index < valuesAndWeights.length; index += 2) {
            final Integer score = (Integer) valuesAndWeights[index];
            final Integer weight = (Integer) valuesAndWeights[index + 1];
            if (score == null || weight == null || weight <= 0) {
                continue;
            }
            weightedSum += score * weight;
            totalWeight += weight;
        }
        if (totalWeight == 0) {
            return 50;
        }
        return (int) Math.round(weightedSum / totalWeight);
    }

    private String resolveFactorTitle(String factorCode) {
        return switch (blankToEmpty(factorCode)) {
            case "PRICE_MOMENTUM" -> "가격 흐름";
            case "PRICE_STABILITY" -> "가격 안정성";
            case "NEWS_SENTIMENT" -> "관련 뉴스 분석";
            case "FUNDAMENTAL_QUALITY" -> "기업 체력";
            case "VALUATION" -> "밸류에이션";
            case "QUALITY_OF_GROWTH" -> "성장의 질";
            case "USER_FIT" -> "내 투자 상황";
            default -> "추천 팩터";
        };
    }

    private int resolveFactorDisplayOrder(String factorCode) {
        return switch (blankToEmpty(factorCode)) {
            case "PRICE_MOMENTUM" -> 1;
            case "PRICE_STABILITY" -> 2;
            case "NEWS_SENTIMENT" -> 3;
            case "FUNDAMENTAL_QUALITY" -> 4;
            case "VALUATION" -> 5;
            case "QUALITY_OF_GROWTH" -> 6;
            case "USER_FIT" -> 7;
            default -> 99;
        };
    }

    private V4ScoringContext buildV4ScoringContext(
            RecommendationTarget target,
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment,
            int confidence,
            boolean hasHardRisk
    ) {
        final Integer priceMomentumScore = resolvePriceMomentumScore(priceSnapshot);
        final Integer priceStabilityScore = resolvePriceStabilityScore(priceSnapshot);
        final Integer newsScore = newsSentiment.relatedNews().isEmpty()
                ? null
                : normalizeToScore(newsSentiment.weightedSentimentScore());
        final FundamentalQualityAssessment fundamentalQualityAssessment =
                resolveFundamentalQualityAssessment(priceSnapshot);
        final Integer fundamentalQualityScore = resolveFundamentalCoreScore(fundamentalQualityAssessment);
        final Integer valuationScore = fundamentalQualityAssessment == null
                ? null
                : fundamentalQualityAssessment.valuationScore();
        final Integer qualityOfGrowthScore = resolveQualityOfGrowthScore(fundamentalQualityAssessment);
        final String effectiveRiskProfile = resolveEffectiveRiskProfile(target);
        final UserFitAssessment userFitAssessment = resolveUserFitAssessment(
                target,
                priceSnapshot,
                effectiveRiskProfile
        );
        final Integer userFitScore = userFitAssessment.score();
        final int crossFactorAdjustment = resolveCrossFactorAdjustment(
                priceSnapshot,
                newsSentiment,
                priceMomentumScore,
                fundamentalQualityScore
        );
        final int userAdjustment = userFitAssessment.finalUserAdjustment();

        return new V4ScoringContext(
                new RecommendationScoreCalculator.V4Input(
                        priceMomentumScore,
                        priceMomentumScore == null ? 0 : tuningProperties.getFactorWeights().getPriceMomentum(),
                        priceStabilityScore,
                        priceStabilityScore == null ? 0 : tuningProperties.getFactorWeights().getPriceStability(),
                        newsSentiment.relatedNews().isEmpty() ? null : newsSentiment.weightedSentimentScore(),
                        newsScore == null ? 0 : tuningProperties.getFactorWeights().getNewsSentiment(),
                        fundamentalQualityScore,
                        fundamentalQualityScore == null ? 0 : tuningProperties.getFactorWeights().getFundamentalQuality(),
                        valuationScore,
                        valuationScore == null ? 0 : tuningProperties.getFactorWeights().getValuation(),
                        qualityOfGrowthScore,
                        qualityOfGrowthScore == null ? 0 : tuningProperties.getFactorWeights().getQualityOfGrowth(),
                        userFitScore,
                        userFitScore == null ? 0 : tuningProperties.getFactorWeights().getUserFit(),
                        crossFactorAdjustment,
                        userAdjustment,
                        effectiveRiskProfile,
                        priceSnapshot.hasSevereDrop() || hasHardRisk,
                        newsSentiment.hardNegativeOverride(),
                        confidence
                ),
                target,
                priceSnapshot,
                newsSentiment.relatedNews().isEmpty() ? null : newsSentiment.weightedSentimentScore(),
                priceMomentumScore,
                priceStabilityScore,
                newsScore,
                fundamentalQualityScore,
                valuationScore,
                qualityOfGrowthScore,
                userFitScore,
                fundamentalQualityAssessment,
                userFitAssessment
        );
    }

    private Integer resolveFundamentalCoreScore(FundamentalQualityAssessment assessment) {
        if (assessment == null) {
            return null;
        }
        return weightedAverageScores(
                assessment.scaleScore(), 15,
                assessment.profitabilityScore(), 35,
                assessment.safetyScore(), 20,
                assessment.cashFlowScore(), 20,
                assessment.efficiencyScore(), 10
        );
    }

    private Integer resolveQualityOfGrowthScore(FundamentalQualityAssessment assessment) {
        if (assessment == null) {
            return null;
        }

        final Integer baseScore = weightedAverageScores(
                assessment.growthScore(), 30,
                assessment.profitabilityScore(), 25,
                assessment.cashFlowScore(), 25,
                assessment.efficiencyScore(), 10,
                assessment.safetyScore(), 10
        );
        if (baseScore == null) {
            return null;
        }

        int adjustment = 0;
        if (assessment.revenueGrowthYoy() != null) {
            final double revenueGrowth = assessment.revenueGrowthYoy().doubleValue();
            if (revenueGrowth >= 0.40) {
                adjustment += 4;
            } else if (revenueGrowth >= 0.20) {
                adjustment += 2;
            } else if (revenueGrowth >= 0.10) {
                adjustment += 1;
            } else if (revenueGrowth < -0.10) {
                adjustment -= 12;
            } else if (revenueGrowth < 0.0) {
                adjustment -= 6;
            }
        }
        if (assessment.epsTtm() != null) {
            adjustment += assessment.epsTtm().doubleValue() > 0 ? 1 : -12;
        }
        if (assessment.operatingMarginTtm() != null) {
            final double operatingMargin = assessment.operatingMarginTtm().doubleValue();
            if (operatingMargin >= 0.30) {
                adjustment += 3;
            } else if (operatingMargin >= 0.15) {
                adjustment += 1;
            } else if (operatingMargin < 0.0) {
                adjustment -= 10;
            } else if (operatingMargin < 0.05) {
                adjustment -= 5;
            }
        }
        if (assessment.incomeQualityTtm() != null) {
            final double incomeQuality = assessment.incomeQualityTtm().doubleValue();
            if (incomeQuality >= 1.15) {
                adjustment += 2;
            } else if (incomeQuality >= 1.0) {
                adjustment += 1;
            } else if (incomeQuality < 0.75) {
                adjustment -= 10;
            } else if (incomeQuality < 0.90) {
                adjustment -= 4;
            }
        }
        if (assessment.freeCashFlowYieldTtm() != null) {
            final double freeCashFlowYield = assessment.freeCashFlowYieldTtm().doubleValue();
            if (freeCashFlowYield >= 0.05) {
                adjustment += 2;
            } else if (freeCashFlowYield >= 0.02) {
                adjustment += 1;
            } else if (freeCashFlowYield < 0.0) {
                adjustment -= 8;
            } else if (freeCashFlowYield < 0.01) {
                adjustment -= 3;
            }
        }
        if (assessment.growthScore() != null
                && assessment.growthScore() >= 82
                && assessment.profitabilityScore() != null
                && assessment.profitabilityScore() >= 80
                && assessment.cashFlowScore() != null
                && assessment.cashFlowScore() >= 75) {
            adjustment += 3;
        }
        if (assessment.growthScore() != null
                && assessment.growthScore() >= 82
                && ((assessment.cashFlowScore() != null
                && assessment.cashFlowScore() <= 60)
                || (assessment.profitabilityScore() != null
                && assessment.profitabilityScore() <= 55))) {
            adjustment -= 10;
        }
        if (assessment.growthScore() != null
                && assessment.growthScore() <= 45
                && assessment.profitabilityScore() != null
                && assessment.profitabilityScore() <= 45) {
            adjustment -= 8;
        }
        if (assessment.growthScore() != null
                && assessment.growthScore() >= 80
                && assessment.safetyScore() != null
                && assessment.safetyScore() <= 45) {
            adjustment -= 5;
        }
        int finalScore = clampScore(baseScore + adjustment);
        if (assessment.revenueGrowthYoy() != null) {
            final int growthDrivenCeiling = resolveGrowthDrivenCeiling(assessment.revenueGrowthYoy().doubleValue());
            if (assessment.profitabilityScore() != null && assessment.profitabilityScore() >= 82
                    && assessment.cashFlowScore() != null && assessment.cashFlowScore() >= 78) {
                finalScore = Math.min(finalScore, clampScore(growthDrivenCeiling + 1));
            } else {
                finalScore = Math.min(finalScore, growthDrivenCeiling);
            }
        }
        return finalScore;
    }

    private int resolveGrowthDrivenCeiling(double revenueGrowthYoy) {
        return interpolatePiecewise(
                revenueGrowthYoy,
                new double[]{-0.10, 0.0, 0.05, 0.10, 0.20, 0.40, 0.80},
                new int[]{50, 60, 69, 76, 83, 89, 94}
        );
    }

    private Integer resolvePriceMomentumScore(PriceSnapshot priceSnapshot) {
        if (priceSnapshot == null || !priceSnapshot.hasThirtyDayReturn()) {
            return null;
        }

        final RecommendationTuningProperties.PriceMomentum momentum =
                tuningProperties.getPriceMomentum();
        final double return30d = priceSnapshot.thirtyDayReturn();
        int score;
        if (return30d <= -35) {
            score = momentum.getSevereDrawdownScore();
        } else if (return30d <= -20) {
            score = momentum.getDeepPullbackScore();
        } else if (return30d <= -10) {
            score = momentum.getPullbackScore();
        } else if (return30d < -3) {
            score = momentum.getSoftPullbackScore();
        } else if (return30d <= 8) {
            score = momentum.getNeutralScore();
        } else if (return30d <= 15) {
            score = momentum.getHealthyUptrendScore();
        } else if (return30d <= 25) {
            score = momentum.getWarmUptrendScore();
        } else if (return30d <= 40) {
            score = momentum.getOverheatedScore();
        } else {
            score = momentum.getEuphoricScore();
        }

        if (priceSnapshot.changeRate7d() != null) {
            final double return7d = priceSnapshot.changeRate7d();
            if (return7d >= 12) {
                score -= momentum.getSharpWeeklySurgePenalty();
            } else if (return7d >= 7) {
                score -= momentum.getWeeklySurgePenalty();
            } else if (return7d <= -10) {
                score -= momentum.getSharpWeeklyDropPenalty();
            } else if (return7d <= -5) {
                score -= momentum.getWeeklyDropPenalty();
            }

            if (return30d >= -18 && return30d <= -5 && return7d >= 3) {
                score += momentum.getReboundBonus();
            }
            if (return30d >= 0 && return30d <= 12 && return7d >= 1 && return7d <= 4) {
                score += momentum.getStableTrendBonus();
            }
            if (return30d >= 20 && return7d >= 8) {
                score -= momentum.getOverheatPenalty();
            }
            if (return30d >= 12 && return30d <= 25 && return7d >= 5) {
                score -= 4;
            }
            if (return30d >= 30) {
                score -= 6;
            }
        }

        return clampScore(score);
    }

    private Integer resolvePriceStabilityScore(PriceSnapshot priceSnapshot) {
        if (priceSnapshot.changeRate7d() == null && priceSnapshot.thirtyDayReturn() == null) {
            return null;
        }

        final RecommendationTuningProperties.PriceStability stability = tuningProperties.getPriceStability();
        final double abs7 = priceSnapshot.changeRate7d() == null ? 0 : Math.abs(priceSnapshot.changeRate7d());
        final double abs30 = priceSnapshot.thirtyDayReturn() == null ? 0 : Math.abs(priceSnapshot.thirtyDayReturn());
        final double downside7 = priceSnapshot.changeRate7d() == null ? 0 : Math.max(0, -priceSnapshot.changeRate7d());
        final double downside30 = priceSnapshot.thirtyDayReturn() == null ? 0 : Math.max(0, -priceSnapshot.thirtyDayReturn());

        double stress = (abs7 * 0.50) + (abs30 * 0.30) + (downside7 * 0.22) + (downside30 * 0.18);
        if (priceSnapshot.thirtyDayReturn() != null && priceSnapshot.thirtyDayReturn() >= 25) {
            stress += 6;
        } else if (priceSnapshot.thirtyDayReturn() != null && priceSnapshot.thirtyDayReturn() >= 15) {
            stress += 3;
        }
        if (priceSnapshot.changeRate7d() != null && priceSnapshot.changeRate7d() >= 10) {
            stress += 5;
        } else if (priceSnapshot.changeRate7d() != null && priceSnapshot.changeRate7d() >= 6) {
            stress += 3;
        }
        if (priceSnapshot.changeRate7d() != null && priceSnapshot.changeRate7d() <= -10) {
            stress += 6;
        }

        int score;
        if (stress <= 5) {
            score = stability.getStress5Score();
        } else if (stress <= 10) {
            score = stability.getStress10Score();
        } else if (stress <= 20) {
            score = stability.getStress20Score();
        } else if (stress <= 30) {
            score = stability.getStress30Score();
        } else {
            score = stability.getFallbackScore();
        }

        if (downside30 >= 20) {
            score -= 12;
        } else if (downside30 >= 10) {
            score -= 6;
        }
        if (abs7 <= 3 && abs30 <= 10) {
            score += 2;
        }

        return clampScore(score);
    }

    private FundamentalQualityAssessment resolveFundamentalQualityAssessment(PriceSnapshot priceSnapshot) {
        if (priceSnapshot.marketCap() == null
                && priceSnapshot.perValue() == null
                && priceSnapshot.epsTtm() == null
                && priceSnapshot.revenueGrowthYoy() == null
                && priceSnapshot.grossMarginTtm() == null
                && priceSnapshot.netMarginTtm() == null
                && priceSnapshot.operatingMarginTtm() == null
                && priceSnapshot.roeTtm() == null
                && priceSnapshot.roaTtm() == null
                && priceSnapshot.roicTtm() == null
                && priceSnapshot.debtToEquityTtm() == null
                && priceSnapshot.currentRatioTtm() == null
                && priceSnapshot.quickRatioTtm() == null
                && priceSnapshot.assetTurnoverTtm() == null
                && priceSnapshot.freeCashFlowYieldTtm() == null
                && priceSnapshot.operatingCashFlowRatioTtm() == null
                && priceSnapshot.incomeQualityTtm() == null) {
            return null;
        }

        final RecommendationTuningProperties.Fundamental fundamental = tuningProperties.getFundamental();
        final RecommendationTuningProperties.MarketCap marketCapRule = fundamental.getMarketCap();
        final RecommendationTuningProperties.Per perRule = fundamental.getPer();
        final RecommendationTuningProperties.Eps epsRule = fundamental.getEps();
        final RecommendationTuningProperties.RevenueGrowth revenueGrowthRule = fundamental.getRevenueGrowth();
        final RecommendationTuningProperties.OperatingMargin operatingMarginRule = fundamental.getOperatingMargin();
        final RecommendationTuningProperties.Roe roeRule = fundamental.getRoe();
        final RecommendationTuningProperties.DebtToEquity debtRule = fundamental.getDebtToEquity();
        final RecommendationTuningProperties.Combination combinationRule = fundamental.getCombination();

        int marketCapAdjustment = 0;
        int perAdjustment = 0;
        int epsAdjustment = 0;
        int revenueGrowthAdjustment = 0;
        int grossMarginAdjustment = 0;
        int netMarginAdjustment = 0;
        int operatingMarginAdjustment = 0;
        int roeAdjustment = 0;
        int roaAdjustment = 0;
        int roicAdjustment = 0;
        int debtToEquityAdjustment = 0;
        int currentRatioAdjustment = 0;
        int quickRatioAdjustment = 0;
        int assetTurnoverAdjustment = 0;
        int freeCashFlowYieldAdjustment = 0;
        int operatingCashFlowRatioAdjustment = 0;
        int incomeQualityAdjustment = 0;
        int combinationAdjustment = 0;
        String marketCapTier = null;
        String perBand = null;
        String epsBand = null;
        String revenueGrowthBand = null;
        String grossMarginBand = null;
        String netMarginBand = null;
        String operatingMarginBand = null;
        String roeBand = null;
        String roaBand = null;
        String roicBand = null;
        String debtToEquityBand = null;
        String currentRatioBand = null;
        String quickRatioBand = null;
        String assetTurnoverBand = null;
        String freeCashFlowYieldBand = null;
        String operatingCashFlowRatioBand = null;
        String incomeQualityBand = null;
        Integer scaleScore = null;
        Integer valuationScore = null;
        Integer growthScore = null;
        Integer profitabilityScore = null;
        Integer safetyScore = null;
        Integer cashFlowScore = null;
        Integer efficiencyScore = null;
        Integer marketCapMetricScore = null;
        Integer perMetricScore = null;
        Integer epsMetricScore = null;
        Integer revenueMetricScore = null;
        Integer grossMarginMetricScore = null;
        Integer netMarginMetricScore = null;
        Integer operatingMarginMetricScore = null;
        Integer roeMetricScore = null;
        Integer roaMetricScore = null;
        Integer roicMetricScore = null;
        Integer debtMetricScore = null;
        Integer currentRatioMetricScore = null;
        Integer quickRatioMetricScore = null;
        Integer assetTurnoverMetricScore = null;
        Integer freeCashFlowYieldMetricScore = null;
        Integer operatingCashFlowRatioMetricScore = null;
        Integer incomeQualityMetricScore = null;

        if (priceSnapshot.marketCap() != null) {
            final double marketCap = priceSnapshot.marketCap().doubleValue();
            if (marketCap >= marketCapRule.getMegaCapMin()) {
                marketCapAdjustment = marketCapRule.getMegaCapAdjustment();
                marketCapTier = "MEGA_CAP";
                marketCapMetricScore = interpolatePiecewise(
                        marketCap,
                        new double[]{
                                marketCapRule.getMegaCapMin(),
                                marketCapRule.getMegaCapMin() * 2.0,
                                marketCapRule.getMegaCapMin() * 5.0
                        },
                        new int[]{82, 85, 88}
                );
            } else if (marketCap >= marketCapRule.getLargeCapMin()) {
                marketCapAdjustment = marketCapRule.getLargeCapAdjustment();
                marketCapTier = "LARGE_CAP";
                marketCapMetricScore = interpolatePiecewise(
                        marketCap,
                        new double[]{marketCapRule.getLargeCapMin(), marketCapRule.getMegaCapMin()},
                        new int[]{72, 82}
                );
            } else if (marketCap >= marketCapRule.getUpperMidCapMin()) {
                marketCapAdjustment = marketCapRule.getUpperMidCapAdjustment();
                marketCapTier = "UPPER_MID_CAP";
                marketCapMetricScore = interpolatePiecewise(
                        marketCap,
                        new double[]{marketCapRule.getUpperMidCapMin(), marketCapRule.getLargeCapMin()},
                        new int[]{60, 72}
                );
            } else if (marketCap >= marketCapRule.getMidCapMin()) {
                marketCapAdjustment = marketCapRule.getMidCapAdjustment();
                marketCapTier = "MID_CAP";
                marketCapMetricScore = interpolatePiecewise(
                        marketCap,
                        new double[]{marketCapRule.getMidCapMin(), marketCapRule.getUpperMidCapMin()},
                        new int[]{48, 60}
                );
            } else {
                marketCapAdjustment = marketCapRule.getSmallCapAdjustment();
                marketCapTier = "SMALL_CAP";
                marketCapMetricScore = interpolatePiecewise(
                        Math.max(0, marketCap),
                        new double[]{0, marketCapRule.getMidCapMin()},
                        new int[]{34, 48}
                );
            }
        }
        if (priceSnapshot.perValue() != null) {
            final double per = priceSnapshot.perValue().doubleValue();
            if (per > 0 && per <= perRule.getAttractiveMax()) {
                perAdjustment = perRule.getAttractiveAdjustment();
                perBand = "ATTRACTIVE";
                perMetricScore = interpolatePiecewise(
                        per,
                        new double[]{1, Math.max(8, perRule.getAttractiveMax() * 0.6), perRule.getAttractiveMax()},
                        new int[]{90, 86, 80}
                );
            } else if (per > 0 && per <= perRule.getFairMax()) {
                perAdjustment = perRule.getFairAdjustment();
                perBand = "FAIR";
                perMetricScore = interpolatePiecewise(
                        per,
                        new double[]{perRule.getAttractiveMax(), perRule.getFairMax()},
                        new int[]{80, 66}
                );
            } else if (per > 0 && per <= perRule.getExpensiveMax()) {
                perAdjustment = perRule.getExpensiveAdjustment();
                perBand = "EXPENSIVE";
                perMetricScore = interpolatePiecewise(
                        per,
                        new double[]{perRule.getFairMax(), perRule.getExpensiveMax()},
                        new int[]{66, 42}
                );
            } else if (per > perRule.getExpensiveMax()) {
                perAdjustment = perRule.getVeryExpensiveAdjustment();
                perBand = "VERY_EXPENSIVE";
                perMetricScore = interpolatePiecewise(
                        per,
                        new double[]{perRule.getExpensiveMax(), perRule.getExpensiveMax() * 1.6, perRule.getExpensiveMax() * 4.0},
                        new int[]{42, 24, 10}
                );
            } else {
                perAdjustment = perRule.getNegativeOrUnclearAdjustment();
                perBand = "NEGATIVE_OR_UNCLEAR";
                perMetricScore = 35;
            }
        }
        if (priceSnapshot.epsTtm() != null) {
            if (priceSnapshot.epsTtm().doubleValue() > 0) {
                epsAdjustment = epsRule.getPositiveAdjustment();
                epsBand = "POSITIVE";
                epsMetricScore = 72;
            } else {
                epsAdjustment = epsRule.getNegativeAdjustment();
                epsBand = "NEGATIVE";
                epsMetricScore = 18;
            }
        }
        if (priceSnapshot.revenueGrowthYoy() != null) {
            final double revenueGrowth = priceSnapshot.revenueGrowthYoy().doubleValue();
            if (revenueGrowth >= revenueGrowthRule.getExceptionalMin()) {
                revenueGrowthAdjustment = revenueGrowthRule.getExceptionalAdjustment();
                revenueGrowthBand = "EXCEPTIONAL";
                revenueMetricScore = interpolatePiecewise(
                        revenueGrowth,
                        new double[]{revenueGrowthRule.getExceptionalMin(), 0.80, 1.20},
                        new int[]{90, 96, 100}
                );
            } else if (revenueGrowth >= revenueGrowthRule.getStrongMin()) {
                revenueGrowthAdjustment = revenueGrowthRule.getStrongAdjustment();
                revenueGrowthBand = "STRONG";
                revenueMetricScore = interpolatePiecewise(
                        revenueGrowth,
                        new double[]{revenueGrowthRule.getStrongMin(), revenueGrowthRule.getExceptionalMin()},
                        new int[]{76, 90}
                );
            } else if (revenueGrowth >= revenueGrowthRule.getHealthyMin()) {
                revenueGrowthAdjustment = revenueGrowthRule.getHealthyAdjustment();
                revenueGrowthBand = "HEALTHY";
                revenueMetricScore = interpolatePiecewise(
                        revenueGrowth,
                        new double[]{revenueGrowthRule.getHealthyMin(), revenueGrowthRule.getStrongMin()},
                        new int[]{62, 76}
                );
            } else if (revenueGrowth >= revenueGrowthRule.getFlatMin()) {
                revenueGrowthAdjustment = revenueGrowthRule.getFlatAdjustment();
                revenueGrowthBand = "FLAT";
                revenueMetricScore = interpolatePiecewise(
                        revenueGrowth,
                        new double[]{revenueGrowthRule.getFlatMin(), revenueGrowthRule.getHealthyMin()},
                        new int[]{50, 62}
                );
            } else {
                revenueGrowthAdjustment = revenueGrowthRule.getNegativeAdjustment();
                revenueGrowthBand = "NEGATIVE";
                revenueMetricScore = interpolatePiecewise(
                        revenueGrowth,
                        new double[]{-0.30, -0.10, revenueGrowthRule.getFlatMin()},
                        new int[]{12, 32, 50}
                );
            }
        }
        if (priceSnapshot.grossMarginTtm() != null) {
            final double grossMargin = priceSnapshot.grossMarginTtm().doubleValue();
            if (grossMargin >= 0.60) {
                grossMarginBand = "EXCEPTIONAL";
                grossMarginAdjustment = 5;
                grossMarginMetricScore = interpolatePiecewise(
                        grossMargin,
                        new double[]{0.60, 0.80},
                        new int[]{90, 96}
                );
            } else if (grossMargin >= 0.45) {
                grossMarginBand = "STRONG";
                grossMarginAdjustment = 3;
                grossMarginMetricScore = interpolatePiecewise(
                        grossMargin,
                        new double[]{0.45, 0.60},
                        new int[]{76, 90}
                );
            } else if (grossMargin >= 0.25) {
                grossMarginBand = "HEALTHY";
                grossMarginAdjustment = 1;
                grossMarginMetricScore = interpolatePiecewise(
                        grossMargin,
                        new double[]{0.25, 0.45},
                        new int[]{60, 76}
                );
            } else if (grossMargin >= 0.10) {
                grossMarginBand = "WEAK";
                grossMarginAdjustment = -1;
                grossMarginMetricScore = interpolatePiecewise(
                        grossMargin,
                        new double[]{0.10, 0.25},
                        new int[]{40, 60}
                );
            } else {
                grossMarginBand = "NEGATIVE";
                grossMarginAdjustment = -4;
                grossMarginMetricScore = interpolatePiecewise(
                        grossMargin,
                        new double[]{-0.10, 0.10},
                        new int[]{18, 40}
                );
            }
        }
        if (priceSnapshot.netMarginTtm() != null) {
            final double netMargin = priceSnapshot.netMarginTtm().doubleValue();
            if (netMargin >= 0.25) {
                netMarginBand = "EXCEPTIONAL";
                netMarginAdjustment = 5;
                netMarginMetricScore = interpolatePiecewise(
                        netMargin,
                        new double[]{0.25, 0.40},
                        new int[]{88, 96}
                );
            } else if (netMargin >= 0.15) {
                netMarginBand = "STRONG";
                netMarginAdjustment = 3;
                netMarginMetricScore = interpolatePiecewise(
                        netMargin,
                        new double[]{0.15, 0.25},
                        new int[]{74, 88}
                );
            } else if (netMargin >= 0.08) {
                netMarginBand = "HEALTHY";
                netMarginAdjustment = 1;
                netMarginMetricScore = interpolatePiecewise(
                        netMargin,
                        new double[]{0.08, 0.15},
                        new int[]{60, 74}
                );
            } else if (netMargin >= 0.03) {
                netMarginBand = "WEAK";
                netMarginAdjustment = -1;
                netMarginMetricScore = interpolatePiecewise(
                        netMargin,
                        new double[]{0.03, 0.08},
                        new int[]{42, 60}
                );
            } else {
                netMarginBand = "NEGATIVE";
                netMarginAdjustment = -4;
                netMarginMetricScore = interpolatePiecewise(
                        netMargin,
                        new double[]{-0.10, 0.03},
                        new int[]{18, 42}
                );
            }
        }
        if (priceSnapshot.operatingMarginTtm() != null) {
            final double operatingMargin = priceSnapshot.operatingMarginTtm().doubleValue();
            if (operatingMargin >= operatingMarginRule.getExceptionalMin()) {
                operatingMarginAdjustment = operatingMarginRule.getExceptionalAdjustment();
                operatingMarginBand = "EXCEPTIONAL";
                operatingMarginMetricScore = interpolatePiecewise(
                        operatingMargin,
                        new double[]{operatingMarginRule.getExceptionalMin(), 0.60},
                        new int[]{90, 96}
                );
            } else if (operatingMargin >= operatingMarginRule.getStrongMin()) {
                operatingMarginAdjustment = operatingMarginRule.getStrongAdjustment();
                operatingMarginBand = "STRONG";
                operatingMarginMetricScore = interpolatePiecewise(
                        operatingMargin,
                        new double[]{operatingMarginRule.getStrongMin(), operatingMarginRule.getExceptionalMin()},
                        new int[]{76, 90}
                );
            } else if (operatingMargin >= operatingMarginRule.getHealthyMin()) {
                operatingMarginAdjustment = operatingMarginRule.getHealthyAdjustment();
                operatingMarginBand = "HEALTHY";
                operatingMarginMetricScore = interpolatePiecewise(
                        operatingMargin,
                        new double[]{operatingMarginRule.getHealthyMin(), operatingMarginRule.getStrongMin()},
                        new int[]{62, 76}
                );
            } else if (operatingMargin >= operatingMarginRule.getWeakMin()) {
                operatingMarginAdjustment = operatingMarginRule.getWeakAdjustment();
                operatingMarginBand = "WEAK";
                operatingMarginMetricScore = interpolatePiecewise(
                        operatingMargin,
                        new double[]{operatingMarginRule.getWeakMin(), operatingMarginRule.getHealthyMin()},
                        new int[]{42, 62}
                );
            } else {
                operatingMarginAdjustment = operatingMarginRule.getNegativeAdjustment();
                operatingMarginBand = "NEGATIVE";
                operatingMarginMetricScore = interpolatePiecewise(
                        operatingMargin,
                        new double[]{-0.20, operatingMarginRule.getWeakMin()},
                        new int[]{12, 42}
                );
            }
        }
        if (priceSnapshot.roeTtm() != null) {
            final double roe = priceSnapshot.roeTtm().doubleValue();
            if (roe >= roeRule.getExceptionalMin()) {
                roeAdjustment = roeRule.getExceptionalAdjustment();
                roeBand = "EXCEPTIONAL";
                roeMetricScore = interpolatePiecewise(
                        roe,
                        new double[]{roeRule.getExceptionalMin(), 0.90, 1.30},
                        new int[]{90, 96, 100}
                );
            } else if (roe >= roeRule.getStrongMin()) {
                roeAdjustment = roeRule.getStrongAdjustment();
                roeBand = "STRONG";
                roeMetricScore = interpolatePiecewise(
                        roe,
                        new double[]{roeRule.getStrongMin(), roeRule.getExceptionalMin()},
                        new int[]{76, 90}
                );
            } else if (roe >= roeRule.getHealthyMin()) {
                roeAdjustment = roeRule.getHealthyAdjustment();
                roeBand = "HEALTHY";
                roeMetricScore = interpolatePiecewise(
                        roe,
                        new double[]{roeRule.getHealthyMin(), roeRule.getStrongMin()},
                        new int[]{62, 76}
                );
            } else if (roe >= roeRule.getWeakMin()) {
                roeAdjustment = roeRule.getWeakAdjustment();
                roeBand = "WEAK";
                roeMetricScore = interpolatePiecewise(
                        roe,
                        new double[]{roeRule.getWeakMin(), roeRule.getHealthyMin()},
                        new int[]{42, 62}
                );
            } else {
                roeAdjustment = roeRule.getNegativeAdjustment();
                roeBand = "NEGATIVE";
                roeMetricScore = interpolatePiecewise(
                        roe,
                        new double[]{-0.30, roeRule.getWeakMin()},
                        new int[]{10, 42}
                );
            }
        }
        if (priceSnapshot.roaTtm() != null) {
            final double roa = priceSnapshot.roaTtm().doubleValue();
            if (roa >= 0.15) {
                roaBand = "EXCEPTIONAL";
                roaAdjustment = 5;
                roaMetricScore = interpolatePiecewise(
                        roa,
                        new double[]{0.15, 0.25},
                        new int[]{86, 94}
                );
            } else if (roa >= 0.08) {
                roaBand = "STRONG";
                roaAdjustment = 3;
                roaMetricScore = interpolatePiecewise(
                        roa,
                        new double[]{0.08, 0.15},
                        new int[]{72, 86}
                );
            } else if (roa >= 0.04) {
                roaBand = "HEALTHY";
                roaAdjustment = 1;
                roaMetricScore = interpolatePiecewise(
                        roa,
                        new double[]{0.04, 0.08},
                        new int[]{60, 72}
                );
            } else if (roa >= 0.0) {
                roaBand = "WEAK";
                roaAdjustment = -1;
                roaMetricScore = interpolatePiecewise(
                        roa,
                        new double[]{0.0, 0.04},
                        new int[]{42, 60}
                );
            } else {
                roaBand = "NEGATIVE";
                roaAdjustment = -4;
                roaMetricScore = interpolatePiecewise(
                        roa,
                        new double[]{-0.10, 0.0},
                        new int[]{14, 42}
                );
            }
        }
        if (priceSnapshot.roicTtm() != null) {
            final double roic = priceSnapshot.roicTtm().doubleValue();
            if (roic >= 0.20) {
                roicBand = "EXCEPTIONAL";
                roicAdjustment = 6;
                roicMetricScore = interpolatePiecewise(
                        roic,
                        new double[]{0.20, 0.35},
                        new int[]{88, 96}
                );
            } else if (roic >= 0.12) {
                roicBand = "STRONG";
                roicAdjustment = 4;
                roicMetricScore = interpolatePiecewise(
                        roic,
                        new double[]{0.12, 0.20},
                        new int[]{74, 88}
                );
            } else if (roic >= 0.06) {
                roicBand = "HEALTHY";
                roicAdjustment = 2;
                roicMetricScore = interpolatePiecewise(
                        roic,
                        new double[]{0.06, 0.12},
                        new int[]{62, 74}
                );
            } else if (roic >= 0.0) {
                roicBand = "WEAK";
                roicAdjustment = -1;
                roicMetricScore = interpolatePiecewise(
                        roic,
                        new double[]{0.0, 0.06},
                        new int[]{44, 62}
                );
            } else {
                roicBand = "NEGATIVE";
                roicAdjustment = -5;
                roicMetricScore = interpolatePiecewise(
                        roic,
                        new double[]{-0.15, 0.0},
                        new int[]{12, 44}
                );
            }
        }
        if (priceSnapshot.debtToEquityTtm() != null) {
            final double debtToEquity = priceSnapshot.debtToEquityTtm().doubleValue();
            if (debtToEquity <= debtRule.getConservativeMax()) {
                debtToEquityAdjustment = debtRule.getConservativeAdjustment();
                debtToEquityBand = "CONSERVATIVE";
                debtMetricScore = interpolatePiecewise(
                        debtToEquity,
                        new double[]{0.0, debtRule.getConservativeMax()},
                        new int[]{88, 78}
                );
            } else if (debtToEquity <= debtRule.getBalancedMax()) {
                debtToEquityAdjustment = debtRule.getBalancedAdjustment();
                debtToEquityBand = "BALANCED";
                debtMetricScore = interpolatePiecewise(
                        debtToEquity,
                        new double[]{debtRule.getConservativeMax(), debtRule.getBalancedMax()},
                        new int[]{78, 60}
                );
            } else if (debtToEquity <= debtRule.getStretchedMax()) {
                debtToEquityAdjustment = debtRule.getStretchedAdjustment();
                debtToEquityBand = "STRETCHED";
                debtMetricScore = interpolatePiecewise(
                        debtToEquity,
                        new double[]{debtRule.getBalancedMax(), debtRule.getStretchedMax()},
                        new int[]{60, 32}
                );
            } else {
                debtToEquityAdjustment = debtRule.getExcessiveAdjustment();
                debtToEquityBand = "EXCESSIVE";
                debtMetricScore = interpolatePiecewise(
                        debtToEquity,
                        new double[]{debtRule.getStretchedMax(), debtRule.getStretchedMax() * 2.0},
                        new int[]{32, 12}
                );
            }
        }
        if (priceSnapshot.currentRatioTtm() != null) {
            final double currentRatio = priceSnapshot.currentRatioTtm().doubleValue();
            if (currentRatio >= 1.5) {
                currentRatioBand = "STRONG";
                currentRatioAdjustment = 3;
                currentRatioMetricScore = interpolatePiecewise(
                        currentRatio,
                        new double[]{1.5, 3.0},
                        new int[]{78, 88}
                );
            } else if (currentRatio >= 1.0) {
                currentRatioBand = "HEALTHY";
                currentRatioAdjustment = 1;
                currentRatioMetricScore = interpolatePiecewise(
                        currentRatio,
                        new double[]{1.0, 1.5},
                        new int[]{62, 78}
                );
            } else if (currentRatio >= 0.8) {
                currentRatioBand = "WEAK";
                currentRatioAdjustment = -1;
                currentRatioMetricScore = interpolatePiecewise(
                        currentRatio,
                        new double[]{0.8, 1.0},
                        new int[]{42, 62}
                );
            } else {
                currentRatioBand = "NEGATIVE";
                currentRatioAdjustment = -4;
                currentRatioMetricScore = interpolatePiecewise(
                        currentRatio,
                        new double[]{0.2, 0.8},
                        new int[]{14, 42}
                );
            }
        }
        if (priceSnapshot.quickRatioTtm() != null) {
            final double quickRatio = priceSnapshot.quickRatioTtm().doubleValue();
            if (quickRatio >= 1.0) {
                quickRatioBand = "STRONG";
                quickRatioAdjustment = 3;
                quickRatioMetricScore = interpolatePiecewise(
                        quickRatio,
                        new double[]{1.0, 2.0},
                        new int[]{78, 88}
                );
            } else if (quickRatio >= 0.7) {
                quickRatioBand = "HEALTHY";
                quickRatioAdjustment = 1;
                quickRatioMetricScore = interpolatePiecewise(
                        quickRatio,
                        new double[]{0.7, 1.0},
                        new int[]{62, 78}
                );
            } else if (quickRatio >= 0.5) {
                quickRatioBand = "WEAK";
                quickRatioAdjustment = -1;
                quickRatioMetricScore = interpolatePiecewise(
                        quickRatio,
                        new double[]{0.5, 0.7},
                        new int[]{42, 62}
                );
            } else {
                quickRatioBand = "NEGATIVE";
                quickRatioAdjustment = -4;
                quickRatioMetricScore = interpolatePiecewise(
                        quickRatio,
                        new double[]{0.1, 0.5},
                        new int[]{14, 42}
                );
            }
        }
        if (priceSnapshot.assetTurnoverTtm() != null) {
            final double assetTurnover = priceSnapshot.assetTurnoverTtm().doubleValue();
            if (assetTurnover >= 1.0) {
                assetTurnoverBand = "STRONG";
                assetTurnoverAdjustment = 3;
                assetTurnoverMetricScore = interpolatePiecewise(
                        assetTurnover,
                        new double[]{1.0, 2.0},
                        new int[]{74, 88}
                );
            } else if (assetTurnover >= 0.6) {
                assetTurnoverBand = "HEALTHY";
                assetTurnoverAdjustment = 1;
                assetTurnoverMetricScore = interpolatePiecewise(
                        assetTurnover,
                        new double[]{0.6, 1.0},
                        new int[]{60, 74}
                );
            } else if (assetTurnover >= 0.3) {
                assetTurnoverBand = "WEAK";
                assetTurnoverAdjustment = -1;
                assetTurnoverMetricScore = interpolatePiecewise(
                        assetTurnover,
                        new double[]{0.3, 0.6},
                        new int[]{42, 60}
                );
            } else {
                assetTurnoverBand = "NEGATIVE";
                assetTurnoverAdjustment = -4;
                assetTurnoverMetricScore = interpolatePiecewise(
                        assetTurnover,
                        new double[]{0.0, 0.3},
                        new int[]{18, 42}
                );
            }
        }
        if (priceSnapshot.freeCashFlowYieldTtm() != null) {
            final double freeCashFlowYield = priceSnapshot.freeCashFlowYieldTtm().doubleValue();
            if (freeCashFlowYield >= 0.05) {
                freeCashFlowYieldBand = "STRONG";
                freeCashFlowYieldAdjustment = 4;
                freeCashFlowYieldMetricScore = interpolatePiecewise(
                        freeCashFlowYield,
                        new double[]{0.05, 0.10},
                        new int[]{80, 92}
                );
            } else if (freeCashFlowYield >= 0.02) {
                freeCashFlowYieldBand = "HEALTHY";
                freeCashFlowYieldAdjustment = 2;
                freeCashFlowYieldMetricScore = interpolatePiecewise(
                        freeCashFlowYield,
                        new double[]{0.02, 0.05},
                        new int[]{62, 80}
                );
            } else if (freeCashFlowYield >= 0.0) {
                freeCashFlowYieldBand = "WEAK";
                freeCashFlowYieldAdjustment = 0;
                freeCashFlowYieldMetricScore = interpolatePiecewise(
                        freeCashFlowYield,
                        new double[]{0.0, 0.02},
                        new int[]{48, 62}
                );
            } else {
                freeCashFlowYieldBand = "NEGATIVE";
                freeCashFlowYieldAdjustment = -5;
                freeCashFlowYieldMetricScore = interpolatePiecewise(
                        freeCashFlowYield,
                        new double[]{-0.10, 0.0},
                        new int[]{12, 48}
                );
            }
        }
        if (priceSnapshot.operatingCashFlowRatioTtm() != null) {
            final double operatingCashFlowRatio = priceSnapshot.operatingCashFlowRatioTtm().doubleValue();
            if (operatingCashFlowRatio >= 1.0) {
                operatingCashFlowRatioBand = "STRONG";
                operatingCashFlowRatioAdjustment = 4;
                operatingCashFlowRatioMetricScore = interpolatePiecewise(
                        operatingCashFlowRatio,
                        new double[]{1.0, 1.5},
                        new int[]{80, 92}
                );
            } else if (operatingCashFlowRatio >= 0.8) {
                operatingCashFlowRatioBand = "HEALTHY";
                operatingCashFlowRatioAdjustment = 2;
                operatingCashFlowRatioMetricScore = interpolatePiecewise(
                        operatingCashFlowRatio,
                        new double[]{0.8, 1.0},
                        new int[]{62, 80}
                );
            } else if (operatingCashFlowRatio >= 0.5) {
                operatingCashFlowRatioBand = "WEAK";
                operatingCashFlowRatioAdjustment = -1;
                operatingCashFlowRatioMetricScore = interpolatePiecewise(
                        operatingCashFlowRatio,
                        new double[]{0.5, 0.8},
                        new int[]{42, 62}
                );
            } else {
                operatingCashFlowRatioBand = "NEGATIVE";
                operatingCashFlowRatioAdjustment = -5;
                operatingCashFlowRatioMetricScore = interpolatePiecewise(
                        operatingCashFlowRatio,
                        new double[]{0.0, 0.5},
                        new int[]{14, 42}
                );
            }
        }
        if (priceSnapshot.incomeQualityTtm() != null) {
            final double incomeQuality = priceSnapshot.incomeQualityTtm().doubleValue();
            if (incomeQuality >= 1.10) {
                incomeQualityBand = "STRONG";
                incomeQualityAdjustment = 4;
                incomeQualityMetricScore = interpolatePiecewise(
                        incomeQuality,
                        new double[]{1.10, 1.40},
                        new int[]{80, 92}
                );
            } else if (incomeQuality >= 0.95) {
                incomeQualityBand = "HEALTHY";
                incomeQualityAdjustment = 2;
                incomeQualityMetricScore = interpolatePiecewise(
                        incomeQuality,
                        new double[]{0.95, 1.10},
                        new int[]{62, 80}
                );
            } else if (incomeQuality >= 0.80) {
                incomeQualityBand = "WEAK";
                incomeQualityAdjustment = -1;
                incomeQualityMetricScore = interpolatePiecewise(
                        incomeQuality,
                        new double[]{0.80, 0.95},
                        new int[]{44, 62}
                );
            } else {
                incomeQualityBand = "NEGATIVE";
                incomeQualityAdjustment = -5;
                incomeQualityMetricScore = interpolatePiecewise(
                        incomeQuality,
                        new double[]{0.40, 0.80},
                        new int[]{14, 44}
                );
            }
        }

        scaleScore = marketCapMetricScore;
        growthScore = averageScores(epsMetricScore, revenueMetricScore);
        profitabilityScore = averageScores(
                grossMarginMetricScore,
                netMarginMetricScore,
                operatingMarginMetricScore,
                roeMetricScore,
                roaMetricScore,
                roicMetricScore
        );
        safetyScore = averageScores(debtMetricScore, currentRatioMetricScore, quickRatioMetricScore);
        cashFlowScore = averageScores(
                freeCashFlowYieldMetricScore,
                operatingCashFlowRatioMetricScore,
                incomeQualityMetricScore
        );
        efficiencyScore = averageScores(assetTurnoverMetricScore);
        valuationScore = weightedAverageScores(
                perMetricScore, 75,
                freeCashFlowYieldMetricScore, 15,
                marketCapMetricScore, 10
        );

        if (profitabilityScore != null && profitabilityScore >= 80
                && safetyScore != null && safetyScore >= 72
                && cashFlowScore != null && cashFlowScore >= 72) {
            combinationAdjustment += 4;
        }
        if (growthScore != null && growthScore >= 80
                && profitabilityScore != null && profitabilityScore >= 80) {
            combinationAdjustment += 3;
        }
        if (profitabilityScore != null && profitabilityScore <= 45
                && cashFlowScore != null && cashFlowScore <= 45) {
            combinationAdjustment -= 6;
        }
        if (safetyScore != null && safetyScore <= 45
                && cashFlowScore != null && cashFlowScore <= 45) {
            combinationAdjustment -= 4;
        }
        if (valuationScore != null && valuationScore <= 30
                && growthScore != null && growthScore <= 55) {
            combinationAdjustment -= 3;
        }
        if (valuationScore != null
                && valuationScore <= 35
                && growthScore != null
                && growthScore >= 80
                && profitabilityScore != null
                && profitabilityScore >= 76) {
            valuationScore = clampScore(valuationScore + 2);
        }
        if (valuationScore != null
                && valuationScore <= 35
                && cashFlowScore != null
                && cashFlowScore <= 45) {
            valuationScore = clampScore(valuationScore - 8);
        }
        if (valuationScore != null
                && valuationScore >= 78
                && cashFlowScore != null
                && cashFlowScore >= 68) {
            valuationScore = clampScore(valuationScore + 1);
        }
        if (priceSnapshot.perValue() != null
                && priceSnapshot.perValue().doubleValue() >= 100
                && growthScore != null
                && growthScore < 80) {
            valuationScore = clampScore(zeroIfNull(valuationScore) - 6);
        }

        final int weightedScore = weightedAverageScores(
                scaleScore, 8,
                valuationScore, 8,
                growthScore, 16,
                profitabilityScore, 28,
                safetyScore, 16,
                cashFlowScore, 16,
                efficiencyScore, 8
        );
        final int score = Math.max(0, Math.min(weightedScore + combinationAdjustment, 100));

        return new FundamentalQualityAssessment(
                score,
                priceSnapshot.marketCap(),
                priceSnapshot.perValue(),
                priceSnapshot.epsTtm(),
                priceSnapshot.revenueGrowthYoy(),
                priceSnapshot.grossMarginTtm(),
                priceSnapshot.netMarginTtm(),
                priceSnapshot.operatingMarginTtm(),
                priceSnapshot.roeTtm(),
                priceSnapshot.roaTtm(),
                priceSnapshot.roicTtm(),
                priceSnapshot.debtToEquityTtm(),
                priceSnapshot.currentRatioTtm(),
                priceSnapshot.quickRatioTtm(),
                priceSnapshot.assetTurnoverTtm(),
                priceSnapshot.freeCashFlowYieldTtm(),
                priceSnapshot.operatingCashFlowRatioTtm(),
                priceSnapshot.incomeQualityTtm(),
                marketCapAdjustment,
                perAdjustment,
                epsAdjustment,
                revenueGrowthAdjustment,
                grossMarginAdjustment,
                netMarginAdjustment,
                operatingMarginAdjustment,
                roeAdjustment,
                roaAdjustment,
                roicAdjustment,
                debtToEquityAdjustment,
                currentRatioAdjustment,
                quickRatioAdjustment,
                assetTurnoverAdjustment,
                freeCashFlowYieldAdjustment,
                operatingCashFlowRatioAdjustment,
                incomeQualityAdjustment,
                combinationAdjustment,
                marketCapTier,
                perBand,
                epsBand,
                revenueGrowthBand,
                grossMarginBand,
                netMarginBand,
                operatingMarginBand,
                roeBand,
                roaBand,
                roicBand,
                debtToEquityBand,
                currentRatioBand,
                quickRatioBand,
                assetTurnoverBand,
                freeCashFlowYieldBand,
                operatingCashFlowRatioBand,
                incomeQualityBand,
                scaleScore,
                valuationScore,
                growthScore,
                profitabilityScore,
                safetyScore,
                cashFlowScore,
                efficiencyScore,
                buildFundamentalQualitySummary(
                        growthScore,
                        profitabilityScore,
                        safetyScore,
                        cashFlowScore,
                        efficiencyScore,
                        revenueGrowthBand,
                        operatingMarginBand,
                        roeBand,
                        roicBand,
                        debtToEquityBand,
                        currentRatioBand,
                        freeCashFlowYieldBand,
                        combinationAdjustment
                )
        );
    }

    private String buildFundamentalQualitySummary(
            Integer growthScore,
            Integer profitabilityScore,
            Integer safetyScore,
            Integer cashFlowScore,
            Integer efficiencyScore,
            String revenueGrowthBand,
            String operatingMarginBand,
            String roeBand,
            String roicBand,
            String debtToEquityBand,
            String currentRatioBand,
            String freeCashFlowYieldBand,
            int combinationAdjustment
    ) {
        final List<String> parts = new ArrayList<>();
        if (profitabilityScore != null) {
            if (profitabilityScore >= 82) {
                parts.add("수익성이 매우 뛰어나 기업 본업 체력을 높게 평가했어요.");
            } else if (profitabilityScore >= 68) {
                parts.add("수익성은 전반적으로 양호한 편이에요.");
            } else if (profitabilityScore <= 45) {
                parts.add("수익성이 약해 기업 체력을 보수적으로 봤어요.");
            }
        }
        if (growthScore != null) {
            if (growthScore >= 80) {
                parts.add("성장 동력이 강해 미래 체력까지 좋게 반영했어요.");
            } else if (growthScore <= 45) {
                parts.add("성장 탄력이 약해 추가 확인이 필요해요.");
            }
        }
        if (safetyScore != null) {
            if (safetyScore >= 75) {
                parts.add("재무 안정성은 좋은 편이에요.");
            } else if (safetyScore <= 45) {
                parts.add("부채와 유동성 측면은 보수적으로 봤어요.");
            }
        }
        if (cashFlowScore != null) {
            if (cashFlowScore >= 75) {
                parts.add("현금창출력과 이익의 질도 양호해요.");
            } else if (cashFlowScore <= 45) {
                parts.add("현금흐름 품질은 보수적으로 해석했어요.");
            }
        }
        if (efficiencyScore != null && efficiencyScore >= 70) {
            parts.add("자산 활용 효율도 괜찮은 편이에요.");
        }
        if ("EXCEPTIONAL".equals(revenueGrowthBand)) {
            parts.add("매출 성장세가 매우 강해요.");
        }
        if ("EXCEPTIONAL".equals(operatingMarginBand) || "EXCEPTIONAL".equals(roeBand) || "EXCEPTIONAL".equals(roicBand)) {
            parts.add("핵심 수익성 지표가 상위권이에요.");
        }
        if ("CONSERVATIVE".equals(debtToEquityBand) && "STRONG".equals(currentRatioBand)) {
            parts.add("유동성과 레버리지 균형도 좋아요.");
        }
        if ("STRONG".equals(freeCashFlowYieldBand)) {
            parts.add("자유현금흐름 기준으로도 체력이 괜찮아요.");
        }
        if (combinationAdjustment > 0) {
            parts.add("여러 품질 지표가 함께 좋아 추가 가점을 줬어요.");
        } else if (combinationAdjustment < 0) {
            parts.add("약한 지표가 겹쳐 보수적으로 조정했어요.");
        }
        if (parts.isEmpty()) {
            return "수익성, 성장성, 안정성, 현금흐름, 효율 지표를 종합해 기업 체력을 계산했어요.";
        }
        return String.join(" ", parts);
    }

    private UserFitAssessment resolveUserFitAssessment(
            RecommendationTarget target,
            PriceSnapshot priceSnapshot,
            String effectiveRiskProfile
    ) {
        int score = 60;
        final BigDecimal dailyInvestAmount = safeAmount(target.getDailyInvestAmount());
        int dailyInvestScoreAdjustment = 0;
        if (dailyInvestAmount.compareTo(BigDecimal.valueOf(80)) >= 0) {
            dailyInvestScoreAdjustment = -12;
        } else if (dailyInvestAmount.compareTo(BigDecimal.valueOf(40)) >= 0) {
            dailyInvestScoreAdjustment = -5;
        } else if (dailyInvestAmount.compareTo(BigDecimal.valueOf(15)) <= 0) {
            dailyInvestScoreAdjustment = 6;
        }
        score += dailyInvestScoreAdjustment;

        int holdingScoreAdjustment = 0;
        if (target.getHoldingQuantity() != null && target.getHoldingQuantity().compareTo(BigDecimal.ZERO) > 0) {
            holdingScoreAdjustment = 6;
        }
        score += holdingScoreAdjustment;

        Integer daysHeld = null;
        int investmentStartScoreAdjustment = 0;
        if (target.getInvestmentStartDate() != null) {
            daysHeld = (int) java.time.temporal.ChronoUnit.DAYS.between(
                    target.getInvestmentStartDate(),
                    LocalDate.now(HOME_ZONE)
            );
            if (daysHeld < 14) {
                investmentStartScoreAdjustment = -8;
            } else if (daysHeld >= 90) {
                investmentStartScoreAdjustment = 6;
            }
        }
        score += investmentStartScoreAdjustment;

        int memoScoreAdjustment = 0;
        if (!blankToEmpty(target.getMemo()).isBlank()) {
            memoScoreAdjustment = 4;
        }
        score += memoScoreAdjustment;

        int riskProfileAdjustment = tuningProperties
                .ruleFor(effectiveRiskProfile)
                .getUserAdjustment();
        int severeDropAdjustment = priceSnapshot.hasSevereDrop() ? -4 : 0;
        int budgetPressureAdjustment = dailyInvestAmount.compareTo(BigDecimal.valueOf(90)) >= 0 ? -5 : 0;
        int finalUserAdjustment = riskProfileAdjustment + severeDropAdjustment + budgetPressureAdjustment;

        return new UserFitAssessment(
                Math.max(0, Math.min(score, 100)),
                dailyInvestAmount,
                target.getHoldingQuantity(),
                daysHeld,
                dailyInvestScoreAdjustment,
                holdingScoreAdjustment,
                investmentStartScoreAdjustment,
                memoScoreAdjustment,
                riskProfileAdjustment,
                budgetPressureAdjustment,
                severeDropAdjustment,
                finalUserAdjustment,
                effectiveRiskProfile,
                blankToEmpty(target.getInvestmentDnaType()),
                buildUserFitSummary(
                        dailyInvestAmount,
                        target.getHoldingQuantity(),
                        daysHeld,
                        effectiveRiskProfile,
                        riskProfileAdjustment,
                        budgetPressureAdjustment,
                        severeDropAdjustment,
                        finalUserAdjustment
                )
        );
    }

    private int resolveCrossFactorAdjustment(
            PriceSnapshot priceSnapshot,
            NewsSentimentService.NewsSentimentResult newsSentiment,
            Integer priceMomentumScore,
            Integer fundamentalQualityScore
    ) {
        int adjustment = 0;
        if (priceSnapshot.hasThirtyDayReturn() && priceSnapshot.thirtyDayReturn() >= 20 && newsSentiment.weightedSentimentScore() < 0) {
            adjustment -= 8;
        }
        if (priceMomentumScore != null
                && priceMomentumScore >= 65
                && fundamentalQualityScore != null
                && fundamentalQualityScore >= 65
                && newsSentiment.weightedSentimentScore() >= 10) {
            adjustment += 5;
        }
        return adjustment;
    }

    private String resolveEffectiveRiskProfile(RecommendationTarget target) {
        final String investmentDnaType = blankToEmpty(target.getInvestmentDnaType());
        if ("SAFE_FIRST".equals(investmentDnaType)) {
            return "SAFE_FIRST";
        }
        if ("GROWTH_SEEKER".equals(investmentDnaType)) {
            return "GROWTH_SEEKER";
        }
        if ("AGGRESSIVE_INVESTOR".equals(investmentDnaType)
                || "WEALTH_MASTER".equals(investmentDnaType)) {
            return "AGGRESSIVE";
        }

        final String storedRiskProfile = blankToEmpty(target.getRiskProfile());
        if ("CONSERVATIVE".equals(storedRiskProfile)) {
            return "SAFE_FIRST";
        }
        if ("AGGRESSIVE".equals(storedRiskProfile)) {
            return "AGGRESSIVE";
        }
        return "BALANCED";
    }

    private String buildUserFitSummary(
            BigDecimal dailyInvestAmount,
            BigDecimal holdingQuantity,
            Integer daysHeld,
            String effectiveRiskProfile,
            int riskProfileAdjustment,
            int budgetPressureAdjustment,
            int severeDropAdjustment,
            int finalUserAdjustment
    ) {
        final List<String> parts = new ArrayList<>();
        parts.add(resolveRiskProfileDisplayName(effectiveRiskProfile) + " 기준을 적용했어요.");

        if (dailyInvestAmount.compareTo(BigDecimal.valueOf(90)) >= 0) {
            parts.add("매일 모으기 금액이 커 부담을 낮추는 쪽으로 봤어요.");
        } else if (dailyInvestAmount.compareTo(BigDecimal.valueOf(15)) <= 0) {
            parts.add("현재 모으기 금액이 크지 않아 비교적 유연하게 반영했어요.");
        }

        if (holdingQuantity != null && holdingQuantity.compareTo(BigDecimal.ZERO) > 0) {
            parts.add("이미 보유 중인 수량이 있어 추격 매수보다 관리 관점도 함께 반영했어요.");
        }

        if (daysHeld != null) {
            if (daysHeld < 14) {
                parts.add("투자 시작 직후라 아직 흐름 확인이 더 필요하다고 봤어요.");
            } else if (daysHeld >= 90) {
                parts.add("장기적으로 모아온 이력이 있어 일관성을 긍정적으로 반영했어요.");
            }
        }

        if (riskProfileAdjustment != 0 || budgetPressureAdjustment != 0 || severeDropAdjustment != 0) {
            parts.add(
                    "사용자 보정은 "
                            + formatSignedNumber(finalUserAdjustment)
                            + "점으로 반영했어요."
            );
        }

        return String.join(" ", parts);
    }

    private String resolveRiskProfileDisplayName(String effectiveRiskProfile) {
        return switch (blankToEmpty(effectiveRiskProfile)) {
            case "SAFE_FIRST" -> "안전 우선형";
            case "GROWTH_SEEKER" -> "성장 추구형";
            case "AGGRESSIVE" -> "공격 투자형";
            default -> "균형형";
        };
    }

    private int normalizeToScore(int value) {
        if (value >= -100 && value <= 100) {
            return Math.max(0, Math.min((int) Math.round((value + 100) / 2.0), 100));
        }
        return Math.max(0, Math.min(value, 100));
    }

    private int resolveCrossFactorAdjustmentFromScoreResult(
            RecommendationScoreCalculator.ScoreResult scoreResult
    ) {
        if (!blankToEmpty(scoreResult.formulaVersion()).startsWith("SCORE_V4")) {
            return 0;
        }
        return scoreResult.riskAdjustment() < 0 ? scoreResult.riskAdjustment() : 0;
    }

    private String buildConfidenceBreakdownJson(
            EngineResult engineResult,
            RecommendationTarget target
    ) {
        try {
            final var node = objectMapper.createObjectNode();
            node.put("finalConfidence", engineResult.confidenceScore());
            node.put("hasInvestmentStartDate", target != null && target.getInvestmentStartDate() != null);
            node.put("hasMemo", target != null && !blankToEmpty(target.getMemo()).isBlank());
            node.put("hasRelatedNews", !engineResult.relatedNews().isEmpty());
            node.put("newsAnalysisConfidence", engineResult.newsAnalysisConfidence());
            node.put("newsCacheReused", engineResult.newsCacheReused());
            return objectMapper.writeValueAsString(node);
        } catch (Exception exception) {
            return "{\"finalConfidence\":" + engineResult.confidenceScore() + "}";
        }
    }

    private NewsSentimentService.NewsSentimentResult buildLightweightNewsSentiment(CachedNewsSummary newsSummary) {
        if (newsSummary.sentimentScore() == null) {
            return NewsSentimentService.NewsSentimentResult.empty();
        }
        return new NewsSentimentService.NewsSentimentResult(
                0,
                newsSummary.sentimentScore() >= 15 ? "POSITIVE"
                        : newsSummary.sentimentScore() <= -15 ? "NEGATIVE" : "NEUTRAL",
                "저장된 관련 뉴스 분석을 먼저 반영했어요.",
                List.of(new NewsSentimentService.AnalyzedNewsItem(
                        "cached-lightweight",
                        "",
                        "저장된 뉴스 분석",
                        "저장된 뉴스 분석",
                        "",
                        "",
                        OffsetDateTime.now(ZoneOffset.UTC),
                        newsSummary.sentimentScore() >= 15 ? "POSITIVE"
                                : newsSummary.sentimentScore() <= -15 ? "NEGATIVE" : "NEUTRAL",
                        newsSummary.sentimentScore(),
                        0,
                        100,
                        "MEDIUM",
                        "저장된 뉴스 분석 결과를 홈 화면에 재사용했어요.",
                        BigDecimal.ONE,
                        BigDecimal.ONE,
                        BigDecimal.ZERO,
                        "cached-lightweight",
                        "cached-lightweight"
                )),
                null,
                newsSummary.sentimentScore(),
                newsSummary.hardNegative(),
                newsSummary.confidence(),
                true,
                false
        );
    }

    private String safeScoreText(Integer score) {
        return score == null ? "-" : String.valueOf(score);
    }

    private String buildFactorEvidenceBody(
            String factorCode,
            String factorSummary,
            Integer factorScore,
            Integer factorWeight,
            String factorRawJson
    ) {
        if ("FUNDAMENTAL_QUALITY".equals(blankToEmpty(factorCode))) {
            return buildFundamentalEvidenceBody(
                    factorSummary,
                    factorScore,
                    factorWeight,
                    factorRawJson
            );
        }
        if ("VALUATION".equals(blankToEmpty(factorCode))
                || "QUALITY_OF_GROWTH".equals(blankToEmpty(factorCode))) {
            return blankToEmpty(factorSummary)
                    + " 점수 "
                    + zeroIfNull(factorScore)
                    + "점, 가중치 "
                    + zeroIfNull(factorWeight)
                    + "을 반영했어요.";
        }
        if ("USER_FIT".equals(blankToEmpty(factorCode))) {
            return buildUserFitEvidenceBody(
                    factorSummary,
                    factorScore,
                    factorWeight,
                    factorRawJson
            );
        }

        return blankToEmpty(factorSummary)
                + " 점수 "
                + zeroIfNull(factorScore)
                + "점, 가중치 "
                + zeroIfNull(factorWeight)
                + "을 반영했어요.";
    }

    private String buildFundamentalEvidenceBody(
            String factorSummary,
            Integer factorScore,
            Integer factorWeight,
            String factorRawJson
    ) {
        try {
            final JsonNode node = objectMapper.readTree(blankToEmpty(factorRawJson));
            final List<String> parts = new ArrayList<>();
            if (!blankToEmpty(factorSummary).isBlank()) {
                parts.add(blankToEmpty(factorSummary));
            }

            appendBandSentence(parts, node.path("marketCapTier").asText(""), switch (node.path("marketCapTier").asText("")) {
                case "MEGA_CAP" -> "초대형주 체급이어서 기본 안정성을 높게 봤어요.";
                case "LARGE_CAP" -> "대형주 체급이라 기본 안정성을 긍정적으로 반영했어요.";
                case "UPPER_MID_CAP" -> "중대형주 체급이라 일정 수준의 버팀력을 반영했어요.";
                case "MID_CAP" -> "중형주 체급으로 중립에 가깝게 반영했어요.";
                case "SMALL_CAP" -> "소형주라 변동 가능성을 감안해 보수적으로 봤어요.";
                default -> "";
            });
            appendBandSentence(parts, node.path("perBand").asText(""), switch (node.path("perBand").asText("")) {
                case "ATTRACTIVE" -> "밸류에이션 부담이 비교적 낮아요.";
                case "FAIR" -> "밸류에이션은 과도하지 않은 편이에요.";
                case "EXPENSIVE" -> "밸류에이션 부담은 다소 있지만 감내 가능한 수준으로 봤어요.";
                case "VERY_EXPENSIVE" -> "밸류에이션 부담이 커서 가점을 제한했어요.";
                case "NEGATIVE_OR_UNCLEAR" -> "PER 해석이 어려워 밸류 평가는 보수적으로 반영했어요.";
                default -> "";
            });
            appendBandSentence(parts, node.path("epsBand").asText(""), switch (node.path("epsBand").asText("")) {
                case "POSITIVE" -> "EPS가 흑자라 기본 수익 체력을 긍정적으로 봤어요.";
                case "NEGATIVE" -> "EPS가 적자라 기본 체력은 보수적으로 봤어요.";
                default -> "";
            });
            appendBandSentence(parts, node.path("revenueGrowthBand").asText(""), switch (node.path("revenueGrowthBand").asText("")) {
                case "EXCEPTIONAL" -> "매출 성장세가 매우 강해 상위권 성장 동력으로 봤어요.";
                case "STRONG" -> "매출 성장세가 강해 성장 동력을 높게 평가했어요.";
                case "HEALTHY" -> "매출이 안정적으로 늘고 있어요.";
                case "FLAT" -> "매출 성장은 크지 않아 중립으로 반영했어요.";
                case "NEGATIVE" -> "매출이 줄어드는 구간이라 감점했어요.";
                default -> "";
            });
            appendBandSentence(parts, node.path("operatingMarginBand").asText(""), switch (node.path("operatingMarginBand").asText("")) {
                case "EXCEPTIONAL" -> "영업이익률이 매우 높아 수익성이 탁월해요.";
                case "STRONG" -> "영업이익률이 높아 수익성이 탄탄해요.";
                case "HEALTHY" -> "영업이익률이 무난하게 유지되고 있어요.";
                case "WEAK" -> "영업이익률은 다소 낮아 추가 확인이 필요해요.";
                case "NEGATIVE" -> "수익성이 약해 체력을 낮게 평가했어요.";
                default -> "";
            });
            appendBandSentence(parts, node.path("roeBand").asText(""), switch (node.path("roeBand").asText("")) {
                case "EXCEPTIONAL" -> "ROE가 매우 높아 자본 효율이 탁월해요.";
                case "STRONG" -> "ROE가 높아 자본 효율이 좋아요.";
                case "HEALTHY" -> "ROE는 양호한 편이에요.";
                case "WEAK" -> "ROE는 중립 수준으로 반영했어요.";
                case "NEGATIVE" -> "ROE가 낮아 효율성은 보수적으로 봤어요.";
                default -> "";
            });
            appendBandSentence(parts, node.path("debtToEquityBand").asText(""), switch (node.path("debtToEquityBand").asText("")) {
                case "CONSERVATIVE" -> "부채 부담이 낮아 재무 안정성은 좋은 편이에요.";
                case "BALANCED" -> "부채 수준은 관리 가능한 범위예요.";
                case "STRETCHED" -> "부채 부담이 있어 점수를 일부 낮췄어요.";
                case "EXCESSIVE" -> "부채 부담이 커 재무 안정성을 낮게 봤어요.";
                default -> "";
            });
            appendSignedAdjustment(parts, "조합 보정", node.path("combinationAdjustment"));
            parts.add("기업 체력 점수 " + zeroIfNull(factorScore) + "점, 가중치 " + zeroIfNull(factorWeight) + "을 반영했어요.");
            return String.join(" ", parts);
        } catch (Exception exception) {
            return blankToEmpty(factorSummary)
                    + " 기업 체력 점수 "
                    + zeroIfNull(factorScore)
                    + "점, 가중치 "
                    + zeroIfNull(factorWeight)
                    + "을 반영했어요.";
        }
    }

    private String buildUserFitEvidenceBody(
            String factorSummary,
            Integer factorScore,
            Integer factorWeight,
            String factorRawJson
    ) {
        try {
            final JsonNode node = objectMapper.readTree(blankToEmpty(factorRawJson));
            final List<String> parts = new ArrayList<>();
            final String riskProfileLabel = node.path("riskProfileLabel").asText("");
            if (!riskProfileLabel.isBlank()) {
                parts.add(riskProfileLabel + " 기준으로 같은 종목이라도 추천 경계를 다르게 봤어요.");
            }

            if (node.path("dailyInvestAmountUsd").isNumber()) {
                final double dailyInvestAmount = node.path("dailyInvestAmountUsd").asDouble();
                parts.add("현재 매일 모으기 금액은 " + formatUsdAmount(dailyInvestAmount) + "예요.");
            }

            if (node.path("daysHeld").isInt()) {
                final int daysHeld = node.path("daysHeld").asInt();
                if (daysHeld < 14) {
                    parts.add("투자를 시작한 지 얼마 되지 않아 조금 더 보수적으로 봤어요.");
                } else if (daysHeld >= 90) {
                    parts.add("오래 모아온 이력이 있어 일관성을 긍정적으로 반영했어요.");
                }
            }

            appendSignedAdjustment(parts, "성향 보정", node.path("riskProfileAdjustment"));
            appendSignedAdjustment(parts, "금액 부담 보정", node.path("budgetPressureAdjustment"));
            appendSignedAdjustment(parts, "급락 구간 보정", node.path("severeDropAdjustment"));
            appendSignedAdjustment(parts, "최종 사용자 보정", node.path("finalUserAdjustment"));

            parts.add("내 투자 상황 점수 " + zeroIfNull(factorScore) + "점, 가중치 " + zeroIfNull(factorWeight) + "을 반영했어요.");
            return String.join(" ", parts);
        } catch (Exception exception) {
            return blankToEmpty(factorSummary)
                    + " 점수 "
                    + zeroIfNull(factorScore)
                    + "점, 가중치 "
                    + zeroIfNull(factorWeight)
                    + "을 반영했어요.";
        }
    }

    private void appendSignedAdjustment(List<String> parts, String label, JsonNode node) {
        if (node == null || !node.isInt()) {
            return;
        }
        final int value = node.asInt();
        if (value == 0) {
            return;
        }
        parts.add(label + "은 " + formatSignedNumber(value) + "점이에요.");
    }

    private void appendBandSentence(List<String> parts, String band, String sentence) {
        if (band == null || band.isBlank() || sentence == null || sentence.isBlank()) {
            return;
        }
        parts.add(sentence);
    }

    private String buildPriceMomentumSummary(PriceSnapshot priceSnapshot) {
        if (priceSnapshot == null || !priceSnapshot.hasThirtyDayReturn()) {
            return "최근 가격 흐름 데이터가 부족해 모멘텀 평가는 보수적으로 반영했어요.";
        }
        final Double return30d = priceSnapshot.thirtyDayReturn();
        final Double return7d = priceSnapshot.changeRate7d();
        if (return30d == null) {
            return "최근 가격 흐름 데이터가 부족해 모멘텀 평가는 보수적으로 반영했어요.";
        }
        if (return30d >= 25 && return7d != null && return7d >= 8) {
            return "최근 30일 상승 폭에 더해 7일 흐름도 가팔라 단기 과열 가능성을 크게 반영했어요.";
        }
        if (return30d >= 15 && return7d != null && return7d >= 5) {
            return "최근 30일 상승세가 강한데 7일 속도도 빨라, 좋은 흐름이어도 추격 부담을 함께 반영했어요.";
        }
        if (return30d >= 15) {
            return "최근 30일 흐름은 강하지만, 지금은 추격 매수보다 가격 부담을 함께 보는 구간이에요.";
        }
        if (return30d >= 5 && return7d != null && return7d >= 1 && return7d <= 4) {
            return "최근 30일과 7일 흐름이 함께 완만하게 우상향하지만, 과한 낙관 없이 적정 구간인지 같이 봤어요.";
        }
        if (return30d >= 5) {
            return "최근 30일 흐름이 우상향이지만, 단기 속도는 함께 확인했어요.";
        }
        if (return30d <= -10 && return7d != null && return7d >= 3) {
            return "최근 30일 조정 이후 7일 반등 흐름이 보여 과도한 약세로만 보지는 않았어요.";
        }
        if (return30d <= -10) {
            return "최근 30일 조정 폭이 커 아직 약세 흐름을 더 확인해야 하는 구간이에요.";
        }
        if (return30d <= -3) {
            return "최근 30일 흐름이 다소 약해 보수적으로 반영했어요.";
        }
        return "최근 30일 흐름은 중립 범위로 봤어요.";
    }

    private String buildPriceStabilitySummary(PriceSnapshot priceSnapshot) {
        if (priceSnapshot == null) {
            return "변동성과 하방 리스크를 기준으로 안정성을 평가했어요.";
        }
        if (priceSnapshot.hasSevereDrop()) {
            return "최근 낙폭이 커 하방 리스크를 높게 반영했어요.";
        }
        final Double abs7d = absoluteOrNull(priceSnapshot.changeRate7d());
        final Double abs30d = absoluteOrNull(priceSnapshot.thirtyDayReturn());
        if (abs7d != null && abs30d != null && abs7d <= 3 && abs30d <= 10) {
            return "최근 7일과 30일 변동폭이 모두 크지 않아 가격 흔들림은 비교적 잔잔한 편이에요.";
        }
        if (abs30d != null && abs30d <= 5) {
            return "최근 가격 변동이 크지 않아 안정성은 무난한 편이에요.";
        }
        if (priceSnapshot.thirtyDayReturn() != null
                && priceSnapshot.thirtyDayReturn() >= 15
                && abs7d != null
                && abs7d >= 6) {
            return "상승 흐름 자체는 좋지만 최근 속도와 변동폭이 함께 커져 안정성은 보수적으로 봤어요.";
        }
        if (priceSnapshot.thirtyDayReturn() != null && priceSnapshot.thirtyDayReturn() <= -10) {
            return "최근 하락 구간의 낙폭이 커 하방 안정성은 보수적으로 봤어요.";
        }
        if ((abs7d != null && abs7d >= 10) || (abs30d != null && abs30d >= 20)) {
            return "최근 가격 흔들림이 커 안정성 점수는 보수적으로 반영했어요.";
        }
        return "변동성과 하방 리스크를 기준으로 안정성을 평가했어요.";
    }

    private String buildNewsSentimentSummary(
            Integer rawNewsSentimentScore,
            RecommendationScoreCalculator.V4Input input
    ) {
        if (rawNewsSentimentScore == null) {
            return "관련성 높은 최신 뉴스가 적어 뉴스 평가는 제한적으로 반영했어요.";
        }
        if (input != null && input.hardNegativeNews()) {
            return "강한 악재 뉴스가 확인돼 다른 긍정 기사보다 우선 반영했어요.";
        }
        if (rawNewsSentimentScore >= 40) {
            return "관련 뉴스 분위기가 전반적으로 긍정적이에요.";
        }
        if (rawNewsSentimentScore >= 10) {
            return "관련 뉴스가 다소 긍정적인 편이에요.";
        }
        if (rawNewsSentimentScore <= -20) {
            return "관련 뉴스 분위기가 부정적으로 기울어 있어요.";
        }
        return "관련 뉴스는 전반적으로 중립에 가까웠어요.";
    }

    private String buildFundamentalFactorSummary(FundamentalQualityAssessment assessment) {
        if (assessment == null) {
            return "수익성, 성장성, 안정성, 현금흐름을 함께 반영했어요.";
        }

        final List<String> points = new ArrayList<>();
        if (assessment.profitabilityScore() != null && assessment.profitabilityScore() >= 80) {
            points.add("강한 수익성");
        }
        if (assessment.cashFlowScore() != null && assessment.cashFlowScore() >= 75) {
            points.add("좋은 현금흐름");
        }
        if (assessment.safetyScore() != null && assessment.safetyScore() >= 75) {
            points.add("안정적 재무구조");
        }
        if ("POSITIVE".equals(assessment.epsBand())) {
            points.add("흑자 EPS");
        }
        if ("STRONG".equals(assessment.revenueGrowthBand())) {
            points.add("강한 매출 성장");
        } else if ("EXCEPTIONAL".equals(assessment.revenueGrowthBand())) {
            points.add("매우 강한 매출 성장");
        } else if ("HEALTHY".equals(assessment.revenueGrowthBand())) {
            points.add("안정적 매출 성장");
        }
        if ("EXCEPTIONAL".equals(assessment.operatingMarginBand())) {
            points.add("탁월한 수익성");
        } else if ("STRONG".equals(assessment.operatingMarginBand())) {
            points.add("높은 수익성");
        } else if ("HEALTHY".equals(assessment.operatingMarginBand())) {
            points.add("양호한 수익성");
        }
        if ("EXCEPTIONAL".equals(assessment.roeBand())) {
            points.add("매우 높은 자본 효율");
        } else if ("STRONG".equals(assessment.roeBand()) || "HEALTHY".equals(assessment.roeBand())) {
            points.add("좋은 자본 효율");
        }
        if ("CONSERVATIVE".equals(assessment.debtToEquityBand())) {
            points.add("낮은 부채 부담");
        }

        final List<String> risks = new ArrayList<>();
        if (assessment.cashFlowScore() != null && assessment.cashFlowScore() <= 45) {
            risks.add("약한 현금흐름");
        }
        if (assessment.safetyScore() != null && assessment.safetyScore() <= 45) {
            risks.add("불안한 재무구조");
        }
        if ("NEGATIVE".equals(assessment.epsBand())) {
            risks.add("적자 EPS");
        }
        if ("NEGATIVE".equals(assessment.revenueGrowthBand())) {
            risks.add("매출 역성장");
        }
        if ("NEGATIVE".equals(assessment.operatingMarginBand()) || "WEAK".equals(assessment.operatingMarginBand())) {
            risks.add("약한 수익성");
        }
        if ("NEGATIVE".equals(assessment.roeBand())) {
            risks.add("낮은 자본 효율");
        }
        if ("STRETCHED".equals(assessment.debtToEquityBand()) || "EXCESSIVE".equals(assessment.debtToEquityBand())) {
            risks.add("높은 부채 부담");
        }

        if (!points.isEmpty() && risks.isEmpty()) {
            return String.join(", ", points) + "이 확인돼 기업 체력을 높게 평가했어요.";
        }
        if (points.isEmpty() && !risks.isEmpty()) {
            return String.join(", ", risks) + "이 보여 기업 체력은 보수적으로 봤어요.";
        }
        if (!points.isEmpty()) {
            return String.join(", ", points) + "은 강점이지만 " + String.join(", ", risks) + "은 함께 살폈어요.";
        }
        return blankToEmpty(assessment.summary()).isBlank()
                ? "수익성, 성장성, 안정성, 현금흐름을 함께 반영했어요."
                : assessment.summary();
    }

    private String buildValuationFactorSummary(FundamentalQualityAssessment assessment) {
        if (assessment == null || assessment.perValue() == null) {
            return "현재 밸류에이션 정보가 부족해 가격 부담은 중립적으로 봤어요.";
        }

        final String perText = "현재 PER은 " + formatDecimal(assessment.perValue(), 1) + "배예요.";
        return switch (blankToEmpty(assessment.perBand())) {
            case "ATTRACTIVE" -> perText + " 이익 대비 가격 부담이 낮아 긍정적으로 반영했어요.";
            case "FAIR" -> perText + " 과도하게 비싸지 않은 구간으로 봤어요.";
            case "EXPENSIVE" -> perText + " 기업 체력이 좋아도 지금 가격은 다소 선반영된 구간으로 봤어요.";
            case "VERY_EXPENSIVE" -> perText + " 성장 기대가 높더라도 현재 가격 부담은 크게 반영했어요.";
            default -> perText + " 밸류에이션은 보수적으로 해석했어요.";
        };
    }

    private String buildQualityOfGrowthFactorSummary(FundamentalQualityAssessment assessment) {
        if (assessment == null) {
            return "매출, 이익, 마진, 현금흐름을 함께 보고 성장의 질을 계산했어요.";
        }

        final List<String> parts = new ArrayList<>();
        if (assessment.revenueGrowthYoy() != null) {
            parts.add("매출 성장률은 " + formatPercent(assessment.revenueGrowthYoy()) + "예요.");
        }
        if (assessment.epsTtm() != null) {
            parts.add("EPS는 " + formatDecimal(assessment.epsTtm(), 2) + "예요.");
        }
        if (assessment.operatingMarginTtm() != null) {
            parts.add("영업이익률은 " + formatPercent(assessment.operatingMarginTtm()) + "예요.");
        }
        if (assessment.incomeQualityTtm() != null) {
            parts.add(
                    assessment.incomeQualityTtm().doubleValue() >= 1.0
                            ? "현금흐름이 이익을 잘 뒷받침하고 있어요."
                            : "이익 대비 현금흐름은 조금 더 확인이 필요해요."
            );
        }
        if (assessment.safetyScore() != null && assessment.safetyScore() <= 45) {
            parts.add("성장 수치는 좋아도 재무 안정성은 함께 보수적으로 반영했어요.");
        }

        if (parts.isEmpty()) {
            return "매출, 이익, 마진, 현금흐름을 함께 보고 성장의 질을 계산했어요.";
        }
        return String.join(" ", parts)
                + " 단순 성장률만이 아니라, 그 성장이 수익성과 현금흐름으로 이어지는지도 함께 봤어요.";
    }

    private String formatDecimal(BigDecimal value, int scale) {
        if (value == null) {
            return "-";
        }
        return value.setScale(scale, RoundingMode.HALF_UP).toPlainString();
    }

    private String formatPercent(BigDecimal value) {
        if (value == null) {
            return "-";
        }
        final BigDecimal percent = value.multiply(BigDecimal.valueOf(100));
        final String prefix = percent.compareTo(BigDecimal.ZERO) > 0 ? "+" : "";
        return prefix + percent.setScale(1, RoundingMode.HALF_UP).toPlainString() + "%";
    }

    private String formatUsdAmount(double value) {
        return BigDecimal.valueOf(value)
                .setScale(2, RoundingMode.HALF_UP)
                .stripTrailingZeros()
                .toPlainString() + "달러";
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

    private PriceSnapshot fetchPriceSnapshot(RecommendationTarget target, boolean allowExternalPriceFetch) {
        StockPriceSnapshotRecord latestSnapshot =
                stockPriceSnapshotMapper.findLatestSnapshotByStockId(target.getStockId());
        if (allowExternalPriceFetch && target.getStockId() != null) {
            try {
                final boolean refreshed = stockPriceSnapshotBatchService.ensureRecommendationSnapshot(target.getStockId());
                if (refreshed) {
                    latestSnapshot = stockPriceSnapshotMapper.findLatestSnapshotByStockId(target.getStockId());
                }
            } catch (Exception exception) {
                log.warn(
                        "추천 계산 직전 가격 스냅샷 보강에 실패했습니다. stockId={}, ticker={}",
                        target.getStockId(),
                        target.getTicker(),
                        exception
                );
            }
        }
        if (latestSnapshot != null
                && latestSnapshot.getCurrentPrice() != null
                && latestSnapshot.getCurrentPrice().doubleValue() > 0) {
            return new PriceSnapshot(
                    latestSnapshot.getCurrentPrice().doubleValue(),
                    latestSnapshot.getChangeRate7d() == null
                            ? null
                            : latestSnapshot.getChangeRate7d().doubleValue(),
                    latestSnapshot.getChangeRate30d() == null
                            ? null
                            : latestSnapshot.getChangeRate30d().doubleValue(),
                    latestSnapshot.getMarketCap(),
                    latestSnapshot.getPerValue(),
                    latestSnapshot.getEpsTtm(),
                    latestSnapshot.getRevenueGrowthYoy(),
                    latestSnapshot.getGrossMarginTtm(),
                    latestSnapshot.getNetMarginTtm(),
                    latestSnapshot.getOperatingMarginTtm(),
                    latestSnapshot.getRoeTtm(),
                    latestSnapshot.getRoaTtm(),
                    latestSnapshot.getRoicTtm(),
                    latestSnapshot.getDebtToEquityTtm(),
                    latestSnapshot.getCurrentRatioTtm(),
                    latestSnapshot.getQuickRatioTtm(),
                    latestSnapshot.getAssetTurnoverTtm(),
                    latestSnapshot.getFreeCashFlowYieldTtm(),
                    latestSnapshot.getOperatingCashFlowRatioTtm(),
                    latestSnapshot.getIncomeQualityTtm()
            );
        }

        if (!allowExternalPriceFetch) {
            return PriceSnapshot.unavailable();
        }

        final String apiKey = System.getenv("FINNHUB_API_KEY");
        final String symbol = resolveSymbol(target);

        if (blankToEmpty(apiKey).isBlank() || blankToEmpty(symbol).isBlank()) {
            return PriceSnapshot.unavailable();
        }

        try {
            final Double currentPrice = fetchCurrentPrice(symbol, apiKey);
            return new PriceSnapshot(
                    currentPrice,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null
            );
        } catch (Exception ignored) {
            return PriceSnapshot.unavailable();
        }
    }

    private boolean isSameRecommendationDay(LocalDate recommendationDate) {
        return recommendationDate != null && recommendationDate.equals(LocalDate.now(HOME_ZONE));
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

    /*
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

    */
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
            RecommendationScoreCalculator.ScoreResult scoreResult,
            RecommendationScoreCalculator.V4ScoreResult v4ScoreResult,
            V4ScoringContext v4Context
    ) {
    }

    private record PriceSnapshot(
            Double currentPrice,
            Double changeRate7d,
            Double thirtyDayReturn,
            BigDecimal marketCap,
            BigDecimal perValue,
            BigDecimal epsTtm,
            BigDecimal revenueGrowthYoy,
            BigDecimal grossMarginTtm,
            BigDecimal netMarginTtm,
            BigDecimal operatingMarginTtm,
            BigDecimal roeTtm,
            BigDecimal roaTtm,
            BigDecimal roicTtm,
            BigDecimal debtToEquityTtm,
            BigDecimal currentRatioTtm,
            BigDecimal quickRatioTtm,
            BigDecimal assetTurnoverTtm,
            BigDecimal freeCashFlowYieldTtm,
            BigDecimal operatingCashFlowRatioTtm,
            BigDecimal incomeQualityTtm
    ) {
        static PriceSnapshot unavailable() {
            return new PriceSnapshot(
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null
            );
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

    private record V4ScoringContext(
            RecommendationScoreCalculator.V4Input input,
            RecommendationTarget target,
            PriceSnapshot priceSnapshot,
            Integer rawNewsSentimentScore,
            Integer priceMomentumScore,
            Integer priceStabilityScore,
            Integer newsScore,
            Integer fundamentalQualityScore,
            Integer valuationScore,
            Integer qualityOfGrowthScore,
            Integer userFitScore,
            FundamentalQualityAssessment fundamentalQualityAssessment,
            UserFitAssessment userFitAssessment
    ) {
        int priceMomentumScoreOrZero() {
            return priceMomentumScore == null ? 0 : priceMomentumScore;
        }

        int priceStabilityScoreOrZero() {
            return priceStabilityScore == null ? 0 : priceStabilityScore;
        }

        int newsScoreOrZero() {
            return newsScore == null ? 0 : newsScore;
        }

        int fundamentalQualityScoreOrZero() {
            return fundamentalQualityScore == null ? 0 : fundamentalQualityScore;
        }

        int valuationScoreOrZero() {
            return valuationScore == null ? 0 : valuationScore;
        }

        int qualityOfGrowthScoreOrZero() {
            return qualityOfGrowthScore == null ? 0 : qualityOfGrowthScore;
        }

        int userFitScoreOrZero() {
            return userFitScore == null ? 0 : userFitScore;
        }
    }

    private record FundamentalQualityAssessment(
            int score,
            BigDecimal marketCap,
            BigDecimal perValue,
            BigDecimal epsTtm,
            BigDecimal revenueGrowthYoy,
            BigDecimal grossMarginTtm,
            BigDecimal netMarginTtm,
            BigDecimal operatingMarginTtm,
            BigDecimal roeTtm,
            BigDecimal roaTtm,
            BigDecimal roicTtm,
            BigDecimal debtToEquityTtm,
            BigDecimal currentRatioTtm,
            BigDecimal quickRatioTtm,
            BigDecimal assetTurnoverTtm,
            BigDecimal freeCashFlowYieldTtm,
            BigDecimal operatingCashFlowRatioTtm,
            BigDecimal incomeQualityTtm,
            int marketCapAdjustment,
            int perAdjustment,
            int epsAdjustment,
            int revenueGrowthAdjustment,
            int grossMarginAdjustment,
            int netMarginAdjustment,
            int operatingMarginAdjustment,
            int roeAdjustment,
            int roaAdjustment,
            int roicAdjustment,
            int debtToEquityAdjustment,
            int currentRatioAdjustment,
            int quickRatioAdjustment,
            int assetTurnoverAdjustment,
            int freeCashFlowYieldAdjustment,
            int operatingCashFlowRatioAdjustment,
            int incomeQualityAdjustment,
            int combinationAdjustment,
            String marketCapTier,
            String perBand,
            String epsBand,
            String revenueGrowthBand,
            String grossMarginBand,
            String netMarginBand,
            String operatingMarginBand,
            String roeBand,
            String roaBand,
            String roicBand,
            String debtToEquityBand,
            String currentRatioBand,
            String quickRatioBand,
            String assetTurnoverBand,
            String freeCashFlowYieldBand,
            String operatingCashFlowRatioBand,
            String incomeQualityBand,
            Integer scaleScore,
            Integer valuationScore,
            Integer growthScore,
            Integer profitabilityScore,
            Integer safetyScore,
            Integer cashFlowScore,
            Integer efficiencyScore,
            String summary
    ) {
    }

    private record UserFitAssessment(
            int score,
            BigDecimal dailyInvestAmountUsd,
            BigDecimal holdingQuantity,
            Integer daysHeld,
            int dailyInvestScoreAdjustment,
            int holdingScoreAdjustment,
            int investmentStartScoreAdjustment,
            int memoScoreAdjustment,
            int riskProfileAdjustment,
            int budgetPressureAdjustment,
            int severeDropAdjustment,
            int finalUserAdjustment,
            String effectiveRiskProfile,
            String investmentDnaType,
            String summary
    ) {
    }

    public record SharedNewsAnalysisWarmupResult(
            Map<Long, NewsSentimentService.NewsSentimentResult> newsByStockId,
            int distinctStockCount,
            int cacheReusedCount,
            int refreshedCount,
            int unavailableCount
    ) {
    }

    private record LightweightRecommendationResult(
            RecommendationResponse response,
            LocalDate priceDataDate,
            OffsetDateTime newsAnalyzedAt
    ) {
    }
}
