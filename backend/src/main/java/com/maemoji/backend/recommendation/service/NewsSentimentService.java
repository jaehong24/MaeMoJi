package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.domain.NewsAnalysisCacheRecord;
import com.maemoji.backend.recommendation.dto.NewsEngineStatusResponse;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

@Service
public class NewsSentimentService {

    private static final String DEFAULT_GEMINI_MODEL = "gemini-2.5-flash-lite";
    private static final String DEFAULT_GEMINI_TRANSLATION_MODEL = "gemini-2.5-flash-lite";
    private static final int MAX_GEMINI_CANDIDATES = 6;
    private static final int MAX_GEMINI_ATTEMPTS = 3;
    private static final long GEMINI_RETRY_DELAY_MILLIS = 2500;
    private static final int MAX_DAILY_NEWS = 3;
    private static final int MAX_DISPLAY_TRADING_DAY_GAP = 3;
    private static final int MIN_PRE_ANALYSIS_RELEVANCE = 45;
    private static final int MIN_FINAL_RELEVANCE = 60;
    private static final Duration EXTERNAL_RECHECK_INTERVAL = Duration.ofMinutes(15);
    private static final ZoneId DAILY_NEWS_ZONE = ZoneId.of("Asia/Seoul");
    private static final Pattern HANGUL_PATTERN = Pattern.compile("[가-힣]");
    private static final Logger log = LoggerFactory.getLogger(NewsSentimentService.class);

    private static final Set<String> POSITIVE_KEYWORDS = Set.of(
            "beat", "surge", "growth", "record", "raise", "strong", "expand",
            "win", "profit", "bullish", "upgrade", "approval", "partnership",
            "호재", "수주", "성장", "확대", "강세", "증가", "흑자", "상향", "승인"
    );

    private static final Set<String> NEGATIVE_KEYWORDS = Set.of(
            "miss", "drop", "fall", "cut", "lawsuit", "fraud", "probe",
            "downgrade", "weak", "layoff", "bankruptcy", "delist", "recall",
            "악재", "하락", "부진", "적자", "소송", "조사", "분식", "파산", "상장폐지", "감원"
    );

    private static final Set<String> HARD_NEGATIVE_KEYWORDS = Set.of(
            "fraud", "accounting fraud", "bankruptcy", "chapter 11", "delist",
            "sec investigation", "criminal investigation", "guidance cut", "guidance lowered",
            "분식회계", "회계부정", "파산", "상장폐지", "sec 조사", "가이던스 하향"
    );
    private static final Set<String> NEGATIVE_ACCOUNTING_KEYWORDS = Set.of(
            "fraud", "accounting fraud", "misstatement", "restatement", "회계부정", "분식회계", "허위공시"
    );
    private static final Set<String> NEGATIVE_REGULATORY_KEYWORDS = Set.of(
            "sec investigation", "criminal investigation", "investigation", "probe", "antitrust",
            "regulator", "subpoena", "조사", "수사", "규제", "독점", "제재"
    );
    private static final Set<String> NEGATIVE_GUIDANCE_KEYWORDS = Set.of(
            "guidance cut", "guidance lowered", "guidance", "miss", "earnings miss", "forecast cut",
            "가이던스 하향", "실적 부진", "전망 하향", "예상 하회"
    );
    private static final Set<String> NEGATIVE_LAWSUIT_KEYWORDS = Set.of(
            "lawsuit", "litigation", "recall", "defect", "class action", "소송", "리콜", "결함", "집단소송"
    );
    private static final Set<String> NEGATIVE_LIQUIDITY_KEYWORDS = Set.of(
            "bankruptcy", "chapter 11", "delist", "default", "liquidity", "restructuring",
            "파산", "상장폐지", "채무불이행", "유동성", "구조조정"
    );
    private static final Set<String> NEGATIVE_DEMAND_KEYWORDS = Set.of(
            "slowdown", "demand weakness", "soft demand", "inventory", "margin pressure",
            "수요 둔화", "재고", "마진 압박", "소비 둔화"
    );

    private static final Set<String> COMPANY_STOP_WORDS = Set.of(
            "inc", "incorporated", "corp", "corporation", "company", "co",
            "ltd", "limited", "plc", "holdings", "holding", "group", "class"
    );

    private final ObjectMapper objectMapper;
    private final RecommendationMapper recommendationMapper;
    private final HttpClient httpClient;
    private final Map<Long, Object> analysisLocks = new ConcurrentHashMap<>();

    public NewsSentimentService(
            ObjectMapper objectMapper,
            RecommendationMapper recommendationMapper
    ) {
        this.objectMapper = objectMapper;
        this.recommendationMapper = recommendationMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    public NewsSentimentResult analyze(Long stockId, String symbol, String companyName) {
        if (stockId == null) {
            return analyzeInternal(stockId, symbol, companyName);
        }

        final Object lock = analysisLocks.computeIfAbsent(stockId, ignored -> new Object());
        synchronized (lock) {
            return analyzeInternal(stockId, symbol, companyName);
        }
    }

    private NewsSentimentResult analyzeInternal(Long stockId, String symbol, String companyName) {
        final String finnhubApiKey = System.getenv("FINNHUB_API_KEY");
        if (isBlank(symbol) || isBlank(finnhubApiKey)) {
            return NewsSentimentResult.unavailable();
        }

        try {
            if (stockId != null) {
                final OffsetDateTime latestAnalyzedAt =
                        recommendationMapper.findLatestNewsAnalyzedAtByStockId(stockId);
                if (latestAnalyzedAt != null
                        && latestAnalyzedAt.isAfter(
                                OffsetDateTime.now(ZoneOffset.UTC)
                                        .minus(EXTERNAL_RECHECK_INTERVAL)
                        )) {
                    final NewsSentimentResult recentCachedResult =
                            findCachedDisplayResult(stockId);
                    if (recentCachedResult != null) {
                        return recentCachedResult;
                    }
                }
            }

            final List<RawNewsItem> fetchedNews = fetchCompanyNews(symbol, finnhubApiKey);
            final List<RawNewsItem> candidates = prepareCandidates(fetchedNews, symbol, companyName);
            if (candidates.isEmpty()) {
                return NewsSentimentResult.empty();
            }

            final String analysisBatchHash = buildAnalysisBatchHash(candidates);
            final NewsSentimentResult cachedResult = reuseCachedAnalysis(
                    stockId,
                    analysisBatchHash,
                    resolveGeminiModel()
            );
            if (cachedResult != null) {
                log.info(
                        "기존 Gemini 뉴스 분석을 재사용합니다. symbol={}, articles={}",
                        symbol,
                        cachedResult.relatedNews().size()
                );
                return cachedResult;
            }

            final GeminiBatchResult geminiResult = classifyWithGemini(companyName, symbol, candidates);
            if (geminiResult == null) {
                log.warn("Gemini를 사용할 수 없어 키워드 기반 뉴스 분석으로 대체합니다. symbol={}", symbol);
                return fallbackKeywordAnalysis(symbol, candidates, analysisBatchHash);
            }
            return aggregateResults(symbol, candidates, geminiResult, analysisBatchHash);
        } catch (Exception exception) {
            log.warn("뉴스 감성 분석에 실패했습니다. symbol={}", symbol, exception);
            return NewsSentimentResult.unavailable();
        }
    }

    public NewsSentimentResult findCachedDisplayResult(Long stockId) {
        if (stockId == null) {
            return null;
        }

        final LocalDate latestAllowedTradingDate =
                latestTradingDateOnOrBefore(LocalDate.now(DAILY_NEWS_ZONE));
        final List<NewsAnalysisCacheRecord> cachedRecords =
                recommendationMapper.findLatestNewsAnalysisByStockId(stockId)
                        .stream()
                        .filter(record -> record.getNewsPublishedAt() != null)
                        .filter(record -> {
                            final LocalDate publishedDate = record.getNewsPublishedAt()
                                    .atZoneSameInstant(DAILY_NEWS_ZONE)
                                    .toLocalDate();
                            return tradingDayGap(publishedDate, latestAllowedTradingDate)
                                    <= MAX_DISPLAY_TRADING_DAY_GAP;
                        })
                        .limit(MAX_DAILY_NEWS)
                        .toList();
        if (cachedRecords.isEmpty()) {
            return null;
        }

        final String model = cachedRecords.stream()
                .map(NewsAnalysisCacheRecord::getLlmModel)
                .filter(value -> !isBlank(value))
                .findFirst()
                .orElse(resolveGeminiModel());

        final List<AnalyzedNewsItem> cachedNews = cachedRecords.stream()
                .map(record -> {
                    final double recencyWeight = calculateRecencyWeight(record.getNewsPublishedAt());
                    final double impactWeight = impactWeight(record.getImpactLevel());
                    final double weightedScore = zeroIfNull(record.getSentimentScore())
                            * (zeroIfNull(record.getRelevanceScore()) / 100.0)
                            * recencyWeight
                            * impactWeight;

                    return new AnalyzedNewsItem(
                            record.getNewsId(),
                            record.getSymbol(),
                            record.getHeadline(),
                            record.getSummary(),
                            record.getSourceName(),
                            record.getNewsUrl(),
                            record.getNewsPublishedAt(),
                            record.getSentimentLabel(),
                            zeroIfNull(record.getSentimentScore()),
                            zeroIfNull(record.getKeywordScore()),
                            zeroIfNull(record.getRelevanceScore()),
                            record.getImpactLevel(),
                            record.getReason(),
                            decimal(recencyWeight),
                            decimal(impactWeight),
                            decimal(weightedScore),
                            record.getContentHash(),
                            record.getAnalysisBatchHash()
                    );
                })
                .toList();

        final boolean hardNegativeOverride = cachedNews.stream().anyMatch(item ->
                item.keywordScore() <= -85
                        && item.relevanceScore() >= MIN_FINAL_RELEVANCE
                        && "HIGH".equals(item.impactLevel())
        );
        final String hardNegativeCategory = hardNegativeOverride
                ? resolveHardNegativeCategory(cachedNews)
                : "NONE";

        return finalizeResult(
                cachedNews,
                hardNegativeOverride,
                hardNegativeCategory,
                "",
                model,
                true,
                false
        );
    }

    public NewsEngineStatusResponse getStatus() {
        return new NewsEngineStatusResponse(
                !isBlank(System.getenv("FINNHUB_API_KEY")),
                !isBlank(System.getenv("GEMINI_API_KEY")),
                resolveGeminiModel(),
                true,
                MAX_DAILY_NEWS,
                MIN_FINAL_RELEVANCE
        );
    }

    private List<RawNewsItem> fetchCompanyNews(String symbol, String apiKey) throws Exception {
        final LocalDate to = LocalDate.now();
        final LocalDate from = to.minusDays(7);
        final String uri = "https://finnhub.io/api/v1/company-news?symbol="
                + encode(symbol)
                + "&from="
                + from
                + "&to="
                + to
                + "&token="
                + encode(apiKey);

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
            return List.of();
        }

        final JsonNode root = objectMapper.readTree(response.body());
        if (!root.isArray()) {
            return List.of();
        }

        final List<RawNewsItem> items = new ArrayList<>();
        for (JsonNode node : root) {
            final String headline = node.path("headline").asText("").trim();
            final String summary = node.path("summary").asText("").trim();
            if (headline.isBlank() && summary.isBlank()) {
                continue;
            }

            final String newsId = node.path("id").asText("");
            final String source = node.path("source").asText("");
            final String url = node.path("url").asText("");
            final long publishedEpoch = node.path("datetime").asLong(0);
            final OffsetDateTime publishedAt = publishedEpoch > 0
                    ? OffsetDateTime.ofInstant(Instant.ofEpochSecond(publishedEpoch), ZoneOffset.UTC)
                    : null;
            final String normalizedText = normalizeText(headline + " " + summary);
            final KeywordResult keywordResult = calculateKeywordScore(normalizedText);
            final String contentHash = sha256(
                    normalizeHeadline(headline)
                            + "|"
                            + normalizeText(summary)
                            + "|"
                            + canonicalizeUrl(url)
            );

            items.add(new RawNewsItem(
                    newsId,
                    headline,
                    summary,
                    source,
                    url,
                    publishedAt,
                    keywordResult.score(),
                    keywordResult.hardNegative(),
                    contentHash,
                    0
            ));
        }
        return items;
    }

    private List<RawNewsItem> prepareCandidates(
            List<RawNewsItem> newsItems,
            String symbol,
            String companyName
    ) {
        final Map<String, RawNewsItem> uniqueItems = new LinkedHashMap<>();
        final Set<String> seenNewsIds = new LinkedHashSet<>();
        final Set<String> seenHeadlines = new LinkedHashSet<>();
        for (RawNewsItem item : newsItems) {
            final String normalizedHeadline = normalizeHeadline(item.headline());
            final boolean duplicateId = !isBlank(item.newsId()) && !seenNewsIds.add(item.newsId());
            final boolean duplicateHeadline = !normalizedHeadline.isBlank()
                    && !seenHeadlines.add(normalizedHeadline);
            if (duplicateId || duplicateHeadline) {
                continue;
            }
            uniqueItems.put(item.contentHash(), item);
        }

        final List<RawNewsItem> relevantItems = uniqueItems.values().stream()
                .map(item -> item.withHeuristicRelevance(
                        calculateHeuristicRelevance(item, symbol, companyName)
                ))
                .filter(item -> item.heuristicRelevanceScore() >= MIN_PRE_ANALYSIS_RELEVANCE)
                .toList();

        final List<RawNewsItem> recentItems = relevantItems.stream()
                .filter(this::isWithinRecentDisplayWindow)
                .sorted(
                        Comparator.comparingInt(RawNewsItem::heuristicRelevanceScore)
                                .reversed()
                                .thenComparing(
                                        RawNewsItem::publishedAt,
                                        Comparator.nullsLast(Comparator.reverseOrder())
                                )
                )
                .limit(MAX_GEMINI_CANDIDATES)
                .toList();

        if (!recentItems.isEmpty()) {
            return recentItems;
        }

        return relevantItems.stream()
                .sorted(
                        Comparator.comparing(
                                        RawNewsItem::publishedAt,
                                        Comparator.nullsLast(Comparator.reverseOrder())
                                )
                                .thenComparing(
                                        RawNewsItem::heuristicRelevanceScore,
                                        Comparator.reverseOrder()
                                )
                )
                .limit(MAX_GEMINI_CANDIDATES)
                .toList();
    }

    private boolean isWithinRecentDisplayWindow(RawNewsItem item) {
        if (item.publishedAt() == null) {
            return false;
        }

        final LocalDate today = LocalDate.now(DAILY_NEWS_ZONE);
        final LocalDate latestAllowedTradingDate = latestTradingDateOnOrBefore(today);
        final LocalDate publishedDate = item.publishedAt()
                .atZoneSameInstant(DAILY_NEWS_ZONE)
                .toLocalDate();
        return !publishedDate.isAfter(today)
                && tradingDayGap(publishedDate, latestAllowedTradingDate)
                <= MAX_DISPLAY_TRADING_DAY_GAP;
    }

    private LocalDate latestTradingDateOnOrBefore(LocalDate date) {
        LocalDate cursor = date;
        while (isWeekend(cursor)) {
            cursor = cursor.minusDays(1);
        }
        return cursor;
    }

    private int tradingDayGap(LocalDate olderDate, LocalDate newerDate) {
        if (olderDate == null || newerDate == null) {
            return Integer.MAX_VALUE;
        }
        if (olderDate.isAfter(newerDate)) {
            // 주말에 발행된 오늘 뉴스는 직전 거래일보다 늦지만 여전히 최신 기사입니다.
            return olderDate.isAfter(LocalDate.now(DAILY_NEWS_ZONE))
                    ? Integer.MAX_VALUE
                    : 0;
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

    private int calculateHeuristicRelevance(RawNewsItem item, String symbol, String companyName) {
        final String headline = normalizeText(item.headline());
        final String fullText = normalizeText(item.headline() + " " + item.summary());
        // Finnhub company-news 자체가 종목 뉴스 피드이므로 기본 관련성을 부여합니다.
        int score = 55;

        if (containsWholeWord(headline, symbol)) {
            score = Math.max(score, 90);
        } else if (containsWholeWord(fullText, symbol)) {
            score = Math.max(score, 75);
        }

        final Set<String> companyTokens = extractCompanyTokens(companyName);
        final long headlineMatches = companyTokens.stream()
                .filter(token -> containsWholeWord(headline, token))
                .count();
        final long fullTextMatches = companyTokens.stream()
                .filter(token -> containsWholeWord(fullText, token))
                .count();

        if (headlineMatches > 0) {
            score = Math.max(score, (int) Math.min(100, 75 + (headlineMatches - 1) * 10));
        } else if (fullTextMatches > 0) {
            score = Math.max(score, (int) Math.min(90, 60 + (fullTextMatches - 1) * 10));
        }

        // 직접적인 티커 또는 회사명 언급이 없으면 관련성이 없는 기사로 처리합니다.
        return clamp(score, 0, 100);
    }

    private Set<String> extractCompanyTokens(String companyName) {
        final Set<String> tokens = new LinkedHashSet<>();
        for (String token : normalizeText(companyName).split("\\s+")) {
            if (token.length() < 3 || COMPANY_STOP_WORDS.contains(token)) {
                continue;
            }
            tokens.add(token);
        }
        return tokens;
    }

    private GeminiBatchResult classifyWithGemini(
            String companyName,
            String symbol,
            List<RawNewsItem> candidates
    ) {
        final String geminiApiKey = System.getenv("GEMINI_API_KEY");
        if (isBlank(geminiApiKey)) {
            log.warn("GEMINI_API_KEY가 없어 키워드 기반 뉴스 분석으로 대체합니다. symbol={}", symbol);
            return null;
        }

        try {
            final String geminiModel = resolveGeminiModel();
            final String uri = "https://generativelanguage.googleapis.com/v1beta/models/"
                    + geminiModel
                    + ":generateContent?key="
                    + encode(geminiApiKey);

            final String requestBody = objectMapper.writeValueAsString(Map.of(
                    "generationConfig", Map.of(
                            "responseMimeType", "application/json",
                            "responseJsonSchema", geminiResponseSchema()
                    ),
                    "contents", List.of(
                            Map.of("parts", List.of(
                                    Map.of("text", buildGeminiPrompt(companyName, symbol, candidates))
                            ))
                    )
            ));

            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .timeout(Duration.ofSeconds(30))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody, StandardCharsets.UTF_8))
                    .build();

            final HttpResponse<String> response = sendGeminiRequestWithRetry(request, symbol);
            if (response.statusCode() != 200 || response.body().isBlank()) {
                log.warn(
                        "Gemini 뉴스 분석 호출에 실패했습니다. symbol={}, status={}",
                        symbol,
                        response.statusCode()
                );
                return null;
            }

            final JsonNode responseRoot = objectMapper.readTree(response.body());
            final String jsonText = responseRoot.path("candidates")
                    .path(0)
                    .path("content")
                    .path("parts")
                    .path(0)
                    .path("text")
                    .asText("");
            if (jsonText.isBlank()) {
                log.warn("Gemini 뉴스 분석 응답이 비어 있습니다. symbol={}", symbol);
                return null;
            }

            final JsonNode analysisRoot = objectMapper.readTree(jsonText);
            final JsonNode articlesNode = analysisRoot.path("articles");
            if (!articlesNode.isArray()) {
                log.warn("Gemini 뉴스 분석 응답 형식이 올바르지 않습니다. symbol={}", symbol);
                return null;
            }

            final Map<Integer, GeminiArticleDecision> decisions = new LinkedHashMap<>();
            for (JsonNode articleNode : articlesNode) {
                final int index = articleNode.path("index").asInt(-1);
                if (index < 1 || index > candidates.size()) {
                    continue;
                }

                decisions.put(index, new GeminiArticleDecision(
                        clamp(articleNode.path("sentimentScore").asInt(0), -100, 100),
                        clamp(articleNode.path("relevanceScore").asInt(0), 0, 100),
                        normalizeImpactLevel(articleNode.path("impactLevel").asText("MEDIUM")),
                        articleNode.path("summaryKo").asText(""),
                        articleNode.path("reason").asText("")
                ));
            }

            if (decisions.isEmpty()) {
                log.warn("Gemini가 유효한 기사 분석을 반환하지 않았습니다. symbol={}", symbol);
                return null;
            }

            log.info(
                    "Gemini 기사별 뉴스 분석을 적용했습니다. symbol={}, model={}, analyzed={}",
                    symbol,
                    geminiModel,
                    decisions.size()
            );
            return new GeminiBatchResult(
                    decisions,
                    analysisRoot.path("overallSummary").asText(""),
                    geminiModel
            );
        } catch (Exception exception) {
            log.warn("Gemini 뉴스 분석 중 오류가 발생했습니다. symbol={}", symbol, exception);
            return null;
        }
    }

    private HttpResponse<String> sendGeminiRequestWithRetry(
            HttpRequest request,
            String symbol
    ) throws Exception {
        HttpResponse<String> response = null;
        for (int attempt = 1; attempt <= MAX_GEMINI_ATTEMPTS; attempt++) {
            response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );
            if (response.statusCode() == 200
                    || !isRetryableGeminiStatus(response.statusCode())
                    || attempt == MAX_GEMINI_ATTEMPTS) {
                return response;
            }

            log.warn(
                    "Gemini 뉴스 분석을 재시도합니다. symbol={}, status={}, attempt={}/{}",
                    symbol,
                    response.statusCode(),
                    attempt,
                    MAX_GEMINI_ATTEMPTS
            );
            Thread.sleep(GEMINI_RETRY_DELAY_MILLIS * attempt);
        }
        return response;
    }

    boolean isRetryableGeminiStatus(int statusCode) {
        return statusCode == 429
                || statusCode == 500
                || statusCode == 502
                || statusCode == 503
                || statusCode == 504;
    }

    private Map<String, Object> geminiResponseSchema() {
        final Map<String, Object> articleSchema = Map.of(
                "type", "object",
                "properties", Map.of(
                        "index", Map.of("type", "integer"),
                        "sentimentLabel", Map.of(
                                "type", "string",
                                "enum", List.of("POSITIVE", "NEUTRAL", "NEGATIVE")
                        ),
                        "sentimentScore", Map.of(
                                "type", "integer",
                                "minimum", -100,
                                "maximum", 100
                        ),
                        "relevanceScore", Map.of(
                                "type", "integer",
                                "minimum", 0,
                                "maximum", 100
                        ),
                        "impactLevel", Map.of(
                                "type", "string",
                                "enum", List.of("LOW", "MEDIUM", "HIGH")
                        ),
                        "summaryKo", Map.of("type", "string"),
                        "reason", Map.of("type", "string")
                ),
                "required", List.of(
                        "index",
                        "sentimentLabel",
                        "sentimentScore",
                        "relevanceScore",
                        "impactLevel",
                        "summaryKo",
                        "reason"
                )
        );

        return Map.of(
                "type", "object",
                "properties", Map.of(
                        "overallSummary", Map.of("type", "string"),
                        "articles", Map.of(
                                "type", "array",
                                "items", articleSchema
                        )
                ),
                "required", List.of("overallSummary", "articles")
        );
    }

    private String buildGeminiPrompt(
            String companyName,
            String symbol,
            List<RawNewsItem> candidates
    ) {
        final StringBuilder prompt = new StringBuilder();
        prompt.append("""
                당신은 미국 주식 뉴스 분석기입니다.
                각 기사가 대상 기업의 주가와 장기 적립 투자 판단에 미칠 방향을 문맥으로 분석하세요.
                '실적은 좋지만 가이던스 하향', '기대치 상회지만 이미 주가 반영',
                '산업 수혜지만 해당 기업 직접 관련성 낮음' 같은 혼합 문맥을 구분해야 합니다.
                sentimentScore는 -100(강한 악재)부터 100(강한 호재), relevanceScore는 직접 관련성 0~100입니다.
                impactLevel은 주가 영향 예상 강도입니다.
                summaryKo와 reason은 반드시 자연스러운 한국어로만 작성하세요.
                영어 문장을 그대로 복사하지 말고, 한국어 투자 앱에 표시할 짧은 문장으로 정리하세요.
                """);
        prompt.append("\n대상 회사: ").append(companyName);
        prompt.append("\n티커: ").append(symbol).append("\n\n");

        for (int index = 0; index < candidates.size(); index++) {
            final RawNewsItem item = candidates.get(index);
            prompt.append(index + 1)
                    .append(". 제목: ")
                    .append(trimForPrompt(item.headline(), 180))
                    .append("\n요약: ")
                    .append(trimForPrompt(item.summary(), 320))
                    .append("\n1차 키워드 점수: ")
                    .append(item.keywordScore())
                    .append("\n1차 관련성 점수: ")
                    .append(item.heuristicRelevanceScore())
                    .append("\n\n");
        }
        return prompt.toString();
    }

    private String trimForPrompt(String value, int maxLength) {
        final String normalized = defaultIfBlank(value, "").trim();
        if (normalized.length() <= maxLength) {
            return normalized;
        }
        return normalized.substring(0, maxLength) + "...";
    }

    private NewsSentimentResult aggregateResults(
            String symbol,
            List<RawNewsItem> candidates,
            GeminiBatchResult geminiResult,
            String analysisBatchHash
    ) {
        final List<IntermediateAnalyzedNewsItem> analyzedCandidates = new ArrayList<>();
        final Set<String> hardNegativeContentHashes = new LinkedHashSet<>();

        for (int index = 0; index < candidates.size(); index++) {
            final RawNewsItem item = candidates.get(index);
            final GeminiArticleDecision decision = geminiResult.decisions().get(index + 1);
            if (decision == null) {
                continue;
            }

            int sentimentScore = clamp(
                    (int) Math.round(decision.sentimentScore() * 0.85 + item.keywordScore() * 0.15),
                    -100,
                    100
            );
            final int relevanceScore = clamp(
                    (int) Math.round(decision.relevanceScore() * 0.8
                            + item.heuristicRelevanceScore() * 0.2),
                    0,
                    100
            );

            if (relevanceScore < MIN_FINAL_RELEVANCE) {
                continue;
            }

            String impactLevel = decision.impactLevel();
            String reason = defaultIfBlank(
                    decision.reason(),
                    fallbackReason(item.keywordScore(), relevanceScore)
            );

            final boolean relevantHardNegative = item.hardNegative() && relevanceScore >= 60;
            if (relevantHardNegative) {
                sentimentScore = Math.min(sentimentScore, -85);
                impactLevel = "HIGH";
                reason = "강한 악재 키워드가 확인되어 우선 반영했습니다. " + reason;
                hardNegativeContentHashes.add(item.contentHash());
            }

            final double recencyWeight = calculateRecencyWeight(item.publishedAt());
            final double impactWeight = impactWeight(impactLevel);
            final double articleWeight = (relevanceScore / 100.0) * recencyWeight * impactWeight;
            final double weightedScore = sentimentScore * articleWeight;
            analyzedCandidates.add(new IntermediateAnalyzedNewsItem(
                    item.newsId(),
                    symbol,
                    item.headline(),
                    defaultIfBlank(decision.summaryKo(), ""),
                    item.sourceName(),
                    item.url(),
                    item.publishedAt(),
                    labelFromScore(sentimentScore),
                    sentimentScore,
                    item.keywordScore(),
                    relevanceScore,
                    impactLevel,
                    defaultIfBlank(reason, ""),
                    decimal(recencyWeight),
                    decimal(impactWeight),
                    decimal(weightedScore),
                    item.contentHash(),
                    analysisBatchHash,
                    item.summary()
            ));
        }

        final List<AnalyzedNewsItem> analyzedNews = finalizeKoreanNewsContent(analyzedCandidates).stream()
                .sorted((left, right) -> {
                    final int byImpact = right.weightedScore().abs().compareTo(left.weightedScore().abs());
                    if (byImpact != 0) {
                        return byImpact;
                    }
                    return Comparator.nullsLast(Comparator.<OffsetDateTime>reverseOrder())
                            .compare(left.newsPublishedAt(), right.newsPublishedAt());
                })
                .limit(MAX_DAILY_NEWS)
                .toList();

        if (analyzedNews.isEmpty()) {
            return NewsSentimentResult.empty();
        }

        final boolean hardNegativeOverride = analyzedNews.stream()
                .map(AnalyzedNewsItem::contentHash)
                .anyMatch(hardNegativeContentHashes::contains);
        final String hardNegativeCategory = hardNegativeOverride
                ? resolveHardNegativeCategory(analyzedNews)
                : "NONE";

        return finalizeResult(
                analyzedNews,
                hardNegativeOverride,
                hardNegativeCategory,
                geminiResult.overallSummary(),
                geminiResult.model(),
                false,
                true
        );
    }

    private NewsSentimentResult fallbackKeywordAnalysis(
            String symbol,
            List<RawNewsItem> candidates,
            String analysisBatchHash
    ) {
        final List<AnalyzedNewsItem> analyzedNews = finalizeKoreanNewsContent(
                candidates.stream()
                .map(item -> {
                    final int relevanceScore = clamp(item.heuristicRelevanceScore(), 0, 100);
                    if (relevanceScore < MIN_FINAL_RELEVANCE) {
                        return null;
                    }

                    int sentimentScore = item.keywordScore();
                    String impactLevel = inferImpactLevel(sentimentScore, item.hardNegative());
                    String reason = fallbackReason(sentimentScore, relevanceScore);

                    if (item.hardNegative() && relevanceScore >= MIN_FINAL_RELEVANCE) {
                        sentimentScore = Math.min(sentimentScore, -85);
                        impactLevel = "HIGH";
                        reason = "강한 악재 키워드가 확인되어 우선 반영했습니다. " + reason;
                    }

                    final double recencyWeight = calculateRecencyWeight(item.publishedAt());
                    final double impactWeight = impactWeight(impactLevel);
                    final double articleWeight = (relevanceScore / 100.0) * recencyWeight * impactWeight;
                    final double weightedScore = sentimentScore * articleWeight;
                    return new IntermediateAnalyzedNewsItem(
                            item.newsId(),
                            symbol,
                            item.headline(),
                            "",
                            item.sourceName(),
                            item.url(),
                            item.publishedAt(),
                            labelFromScore(sentimentScore),
                            sentimentScore,
                            item.keywordScore(),
                            relevanceScore,
                            impactLevel,
                            "",
                            decimal(recencyWeight),
                            decimal(impactWeight),
                            decimal(weightedScore),
                            item.contentHash(),
                            analysisBatchHash,
                            item.summary()
                    );
                })
                .filter(item -> item != null)
                .toList()
        ).stream()
                .sorted((left, right) -> {
                    final int byImpact = right.weightedScore().abs().compareTo(left.weightedScore().abs());
                    if (byImpact != 0) {
                        return byImpact;
                    }
                    return Comparator.nullsLast(Comparator.<OffsetDateTime>reverseOrder())
                            .compare(left.newsPublishedAt(), right.newsPublishedAt());
                })
                .limit(MAX_DAILY_NEWS)
                .toList();

        if (analyzedNews.isEmpty()) {
            return NewsSentimentResult.geminiUnavailable();
        }

        final boolean hardNegativeOverride = analyzedNews.stream().anyMatch(item ->
                item.keywordScore() <= -85
                        && item.relevanceScore() >= MIN_FINAL_RELEVANCE
                        && "HIGH".equals(item.impactLevel())
        );
        final String hardNegativeCategory = hardNegativeOverride
                ? resolveHardNegativeCategory(analyzedNews)
                : "NONE";

        return finalizeResult(
                analyzedNews,
                hardNegativeOverride,
                hardNegativeCategory,
                "Gemini 응답이 일시적으로 불안정해 키워드 기반 1차 뉴스 분석으로 대체했습니다.",
                "KEYWORD_FALLBACK",
                false,
                true
        );
    }

    private NewsSentimentResult reuseCachedAnalysis(
            Long stockId,
            String analysisBatchHash,
            String geminiModel
    ) {
        if (stockId == null) {
            return null;
        }

        final List<NewsAnalysisCacheRecord> cachedRecords =
                recommendationMapper.findLatestNewsAnalysisByStockId(stockId);
        if (cachedRecords.isEmpty()) {
            return null;
        }

        final boolean cacheMatches = cachedRecords.stream().allMatch(record ->
                analysisBatchHash.equals(record.getAnalysisBatchHash())
                        && geminiModel.equals(record.getLlmModel())
                        && record.getRelevanceScore() != null
                        && record.getRelevanceScore() >= MIN_FINAL_RELEVANCE
        );
        if (!cacheMatches) {
            return null;
        }

        final List<AnalyzedNewsItem> cachedNews = cachedRecords.stream()
                .map(record -> {
                    final double recencyWeight = calculateRecencyWeight(record.getNewsPublishedAt());
                    final double impactWeight = impactWeight(record.getImpactLevel());
                    final double weightedScore = zeroIfNull(record.getSentimentScore())
                            * (zeroIfNull(record.getRelevanceScore()) / 100.0)
                            * recencyWeight
                            * impactWeight;

                    return new AnalyzedNewsItem(
                            record.getNewsId(),
                            record.getSymbol(),
                            record.getHeadline(),
                            record.getSummary(),
                            record.getSourceName(),
                            record.getNewsUrl(),
                            record.getNewsPublishedAt(),
                            record.getSentimentLabel(),
                            zeroIfNull(record.getSentimentScore()),
                            zeroIfNull(record.getKeywordScore()),
                            zeroIfNull(record.getRelevanceScore()),
                            record.getImpactLevel(),
                            record.getReason(),
                            decimal(recencyWeight),
                            decimal(impactWeight),
                            decimal(weightedScore),
                            record.getContentHash(),
                            record.getAnalysisBatchHash()
                    );
                })
                .toList();

        final boolean hardNegativeOverride = cachedNews.stream().anyMatch(item ->
                item.keywordScore() <= -85
                        && item.relevanceScore() >= MIN_FINAL_RELEVANCE
                        && "HIGH".equals(item.impactLevel())
        );

        return finalizeResult(
                cachedNews,
                hardNegativeOverride,
                "",
                geminiModel,
                true,
                false
        );
    }

    private NewsSentimentResult finalizeResult(
            List<AnalyzedNewsItem> analyzedNews,
            boolean hardNegativeOverride,
            String hardNegativeCategory,
            String geminiSummary,
            String geminiModel,
            boolean cacheReused,
            boolean replaceCache
    ) {
        double weightedTotal = 0;
        double totalWeight = 0;
        int positiveCount = 0;
        int negativeCount = 0;
        double relevanceTotal = 0;

        for (AnalyzedNewsItem item : analyzedNews) {
            final double articleWeight = item.relevanceScore() / 100.0
                    * item.recencyWeight().doubleValue()
                    * item.impactWeight().doubleValue();
            weightedTotal += item.weightedScore().doubleValue();
            totalWeight += articleWeight;
            relevanceTotal += item.relevanceScore();

            if (item.sentimentScore() >= 15) {
                positiveCount++;
            } else if (item.sentimentScore() <= -15) {
                negativeCount++;
            }
        }

        final int rawAggregateScore = totalWeight == 0
                ? 0
                : clamp((int) Math.round(weightedTotal / totalWeight), -100, 100);
        final double evidenceFactor = switch (analyzedNews.size()) {
            case 1 -> 0.65;
            case 2 -> 0.85;
            default -> 1.0;
        };
        final double consensusFactor = positiveCount > 0 && negativeCount > 0 ? 0.8 : 1.0;
        int aggregateScore = clamp(
                (int) Math.round(rawAggregateScore * evidenceFactor * consensusFactor),
                -100,
                100
        );

        if (hardNegativeOverride) {
            aggregateScore = Math.min(aggregateScore, -70);
        }

        final double averageRelevance = analyzedNews.isEmpty()
                ? 0
                : relevanceTotal / analyzedNews.size();
        final int analysisConfidence = clamp(
                (int) Math.round(
                        35
                                + analyzedNews.size() * 12
                                + averageRelevance * 0.25
                                + consensusFactor * 10
                ),
                0,
                95
        );

        return new NewsSentimentResult(
                mapToEngineScore(aggregateScore),
                labelFromScore(aggregateScore),
                buildOverallSummary(aggregateScore, hardNegativeOverride, hardNegativeCategory, geminiSummary),
                analyzedNews,
                geminiModel,
                aggregateScore,
                hardNegativeOverride,
                defaultIfBlank(hardNegativeCategory, "NONE"),
                analysisConfidence,
                cacheReused,
                replaceCache
        );
    }

    private NewsSentimentResult finalizeResult(
            List<AnalyzedNewsItem> analyzedNews,
            boolean hardNegativeOverride,
            String geminiSummary,
            String geminiModel,
            boolean cacheReused,
            boolean replaceCache
    ) {
        return finalizeResult(
                analyzedNews,
                hardNegativeOverride,
                hardNegativeOverride ? resolveHardNegativeCategory(analyzedNews) : "NONE",
                geminiSummary,
                geminiModel,
                cacheReused,
                replaceCache
        );
    }

    private KeywordResult calculateKeywordScore(String text) {
        int score = 0;
        for (String keyword : POSITIVE_KEYWORDS) {
            if (containsKeyword(text, keyword)) {
                score += 18;
            }
        }
        for (String keyword : NEGATIVE_KEYWORDS) {
            if (containsKeyword(text, keyword)) {
                score -= 20;
            }
        }

        final boolean hardNegative = HARD_NEGATIVE_KEYWORDS.stream()
                .anyMatch(keyword -> containsKeyword(text, keyword));
        if (hardNegative) {
            score = Math.min(score, -85);
        }
        return new KeywordResult(clamp(score, -100, 100), hardNegative);
    }

    private int mapToEngineScore(int aggregateScore) {
        if (aggregateScore <= -70) {
            return 1;
        }
        if (aggregateScore <= -40) {
            return 3;
        }
        if (aggregateScore <= -15) {
            return 6;
        }
        if (aggregateScore < 15) {
            return 9;
        }
        if (aggregateScore < 40) {
            return 11;
        }
        if (aggregateScore < 70) {
            return 13;
        }
        return 15;
    }

    private String labelFromScore(int score) {
        if (score >= 15) {
            return "POSITIVE";
        }
        if (score <= -15) {
            return "NEGATIVE";
        }
        return "NEUTRAL";
    }

    private String inferImpactLevel(int keywordScore, boolean hardNegative) {
        if (hardNegative || Math.abs(keywordScore) >= 70) {
            return "HIGH";
        }
        if (Math.abs(keywordScore) >= 30) {
            return "MEDIUM";
        }
        return "LOW";
    }

    private String normalizeImpactLevel(String value) {
        final String normalized = defaultIfBlank(value, "MEDIUM").toUpperCase(Locale.ROOT);
        return switch (normalized) {
            case "LOW", "MEDIUM", "HIGH" -> normalized;
            default -> "MEDIUM";
        };
    }

    private double calculateRecencyWeight(OffsetDateTime publishedAt) {
        if (publishedAt == null) {
            return 0.65;
        }

        final long hours = Math.max(0, ChronoUnit.HOURS.between(publishedAt, OffsetDateTime.now(ZoneOffset.UTC)));
        if (hours <= 24) {
            return 1.0;
        }
        if (hours <= 72) {
            return 0.85;
        }
        if (hours <= 168) {
            return 0.65;
        }
        return 0.45;
    }

    private double impactWeight(String impactLevel) {
        return switch (impactLevel) {
            case "HIGH" -> 1.35;
            case "LOW" -> 0.75;
            default -> 1.0;
        };
    }

    private String buildOverallSummary(
            int score,
            boolean hardNegativeOverride,
            String hardNegativeCategory,
            String geminiSummary
    ) {
        if (hardNegativeOverride) {
            return negativeCategorySummaryLead(hardNegativeCategory)
                    + " 다른 긍정 기사보다 우선 반영했습니다. "
                    + defaultIfBlank(geminiSummary, "관련 기사 원문과 판단 이유를 함께 확인해 주세요.");
        }
        if (!isBlank(geminiSummary)) {
            return geminiSummary;
        }
        if (score >= 15) {
            return "최근 관련 뉴스는 전반적으로 긍정적이며 최신성과 영향도를 반영한 가중 점수도 양호합니다.";
        }
        if (score <= -15) {
            return "최근 관련 뉴스는 전반적으로 부정적이며 최신성과 영향도를 반영해 보수적으로 평가했습니다.";
        }
        return "최근 관련 뉴스의 긍정과 부정 신호가 혼재해 뉴스 심리를 중립으로 평가했습니다.";
    }

    private String negativeCategorySummaryLead(String hardNegativeCategory) {
        return switch (defaultIfBlank(hardNegativeCategory, "NONE")) {
            case "ACCOUNTING_OR_FRAUD" -> "회계 이슈나 신뢰 훼손 성격의 강한 악재가 확인돼";
            case "LIQUIDITY_OR_BANKRUPTCY" -> "유동성·상장 유지와 연결된 강한 악재가 확인돼";
            case "REGULATORY_INVESTIGATION" -> "규제·조사 성격의 강한 악재가 확인돼";
            case "GUIDANCE_OR_EARNINGS" -> "실적·가이던스 성격의 강한 악재가 확인돼";
            case "LAWSUIT_OR_RECALL" -> "소송·리콜 성격의 강한 악재가 확인돼";
            case "DEMAND_OR_MARGIN" -> "수요 둔화·마진 압박 성격의 강한 악재가 확인돼";
            default -> "직접 관련성이 높은 강한 악재가 확인돼";
        };
    }

    private String fallbackReason(int keywordScore, int relevanceScore) {
        if (keywordScore > 0) {
            return "기사 제목과 요약에서 긍정 신호가 확인됐고, 종목 직접 관련성은 "
                    + relevanceScore
                    + "점으로 높게 봤습니다.";
        }
        if (keywordScore < 0) {
            return "기사 제목과 요약에서 부정 신호가 확인됐고, 종목 직접 관련성은 "
                    + relevanceScore
                    + "점으로 판단했습니다.";
        }
        return "기사 내용의 방향성은 중립에 가깝지만 종목 직접 관련성은 "
                + relevanceScore
                + "점으로 반영했습니다.";
    }

    private String resolveHardNegativeCategory(List<AnalyzedNewsItem> analyzedNews) {
        int accounting = 0;
        int liquidity = 0;
        int regulatory = 0;
        int guidance = 0;
        int lawsuit = 0;
        int demand = 0;

        for (AnalyzedNewsItem item : analyzedNews) {
            final String text = normalizeText(
                    defaultIfBlank(item.headline(), "")
                            + " "
                            + defaultIfBlank(item.summary(), "")
                            + " "
                            + defaultIfBlank(item.reason(), "")
            );
            final int weight = "HIGH".equals(item.impactLevel()) ? 2 : 1;
            if (containsAnyKeyword(text, NEGATIVE_ACCOUNTING_KEYWORDS)) {
                accounting += weight;
            }
            if (containsAnyKeyword(text, NEGATIVE_LIQUIDITY_KEYWORDS)) {
                liquidity += weight;
            }
            if (containsAnyKeyword(text, NEGATIVE_REGULATORY_KEYWORDS)) {
                regulatory += weight;
            }
            if (containsAnyKeyword(text, NEGATIVE_GUIDANCE_KEYWORDS)) {
                guidance += weight;
            }
            if (containsAnyKeyword(text, NEGATIVE_LAWSUIT_KEYWORDS)) {
                lawsuit += weight;
            }
            if (containsAnyKeyword(text, NEGATIVE_DEMAND_KEYWORDS)) {
                demand += weight;
            }
        }

        int bestScore = 0;
        String bestCategory = "GENERAL_HARD_NEGATIVE";
        if (accounting > bestScore) {
            bestScore = accounting;
            bestCategory = "ACCOUNTING_OR_FRAUD";
        }
        if (liquidity > bestScore) {
            bestScore = liquidity;
            bestCategory = "LIQUIDITY_OR_BANKRUPTCY";
        }
        if (regulatory > bestScore) {
            bestScore = regulatory;
            bestCategory = "REGULATORY_INVESTIGATION";
        }
        if (guidance > bestScore) {
            bestScore = guidance;
            bestCategory = "GUIDANCE_OR_EARNINGS";
        }
        if (lawsuit > bestScore) {
            bestScore = lawsuit;
            bestCategory = "LAWSUIT_OR_RECALL";
        }
        if (demand > bestScore) {
            bestCategory = "DEMAND_OR_MARGIN";
        }
        return bestCategory;
    }

    private boolean containsAnyKeyword(String text, Set<String> keywords) {
        for (String keyword : keywords) {
            if (containsKeyword(text, keyword)) {
                return true;
            }
        }
        return false;
    }

    private String fallbackSummary(RawNewsItem item) {
        return !item.summary().isBlank() ? item.summary() : item.headline();
    }

    private List<AnalyzedNewsItem> finalizeKoreanNewsContent(List<IntermediateAnalyzedNewsItem> candidates) {
        if (candidates.isEmpty()) {
            return List.of();
        }

        final Map<Integer, BatchTranslationDecision> translatedByIndex =
                batchTranslateMissingNewsFields(candidates);
        final List<AnalyzedNewsItem> finalized = new ArrayList<>();
        for (int index = 0; index < candidates.size(); index++) {
            final IntermediateAnalyzedNewsItem item = candidates.get(index);
            final BatchTranslationDecision translated = translatedByIndex.get(index + 1);
            final String summaryKo = resolveSummaryKo(item, translated);
            final String reasonKo = resolveReasonKo(item, translated);
            finalized.add(new AnalyzedNewsItem(
                    item.newsId(),
                    item.symbol(),
                    item.headline(),
                    summaryKo,
                    item.sourceName(),
                    item.newsUrl(),
                    item.newsPublishedAt(),
                    item.sentimentLabel(),
                    item.sentimentScore(),
                    item.keywordScore(),
                    item.relevanceScore(),
                    item.impactLevel(),
                    reasonKo,
                    item.recencyWeight(),
                    item.impactWeight(),
                    item.weightedScore(),
                    item.contentHash(),
                    item.analysisBatchHash()
            ));
        }
        return finalized;
    }

    private String resolveSummaryKo(IntermediateAnalyzedNewsItem item, BatchTranslationDecision translated) {
        final String primary = defaultIfBlank(item.summary(), "").trim();
        if (containsHangul(primary)) {
            return primary;
        }
        final String translatedSummary = translated == null ? "" : defaultIfBlank(translated.summaryKo(), "").trim();
        if (containsHangul(translatedSummary)) {
            return translatedSummary;
        }
        return buildGenericKoreanSummary(item.headline(), item.rawSummary());
    }

    private String resolveReasonKo(IntermediateAnalyzedNewsItem item, BatchTranslationDecision translated) {
        final String primary = defaultIfBlank(item.reason(), "").trim();
        if (containsHangul(primary)) {
            return primary;
        }
        final String translatedReason = translated == null ? "" : defaultIfBlank(translated.reasonKo(), "").trim();
        if (containsHangul(translatedReason)) {
            return translatedReason;
        }
        return fallbackReason(item.keywordScore(), item.relevanceScore());
    }

    private String buildGenericKoreanSummary(String headline, String rawSummary) {
        final String normalizedHeadline = defaultIfBlank(headline, "").trim();
        final String normalizedSummary = defaultIfBlank(rawSummary, "").trim();

        if (!normalizedHeadline.isBlank() && !normalizedSummary.isBlank()) {
            return "이 기사는 " + quoteHeadline(normalizedHeadline) + "와 관련된 내용을 다루며, 원문 요약 기준 핵심 흐름을 뉴스 판단에 반영했습니다.";
        }
        if (!normalizedHeadline.isBlank()) {
            return "이 기사는 " + quoteHeadline(normalizedHeadline) + "를 중심으로 한 내용이라 관련 뉴스로 반영했습니다.";
        }
        if (!normalizedSummary.isBlank()) {
            return "원문 요약 기준 종목과 직접 연결되는 내용이 확인되어 관련 뉴스로 반영했습니다.";
        }
        return "기사 원문 기준으로 종목 관련성이 확인되어 뉴스 분석에 반영했습니다.";
    }

    private String quoteHeadline(String headline) {
        return "'" + headline + "'";
    }

    private boolean containsHangul(String value) {
        return !isBlank(value) && HANGUL_PATTERN.matcher(value).find();
    }

    private Map<Integer, BatchTranslationDecision> batchTranslateMissingNewsFields(
            List<IntermediateAnalyzedNewsItem> candidates
    ) {
        final List<Integer> indexesToTranslate = new ArrayList<>();
        for (int index = 0; index < candidates.size(); index++) {
            final IntermediateAnalyzedNewsItem item = candidates.get(index);
            final boolean summaryNeedsTranslation = !containsHangul(defaultIfBlank(item.summary(), "").trim());
            final boolean reasonNeedsTranslation = !containsHangul(defaultIfBlank(item.reason(), "").trim());
            if (summaryNeedsTranslation || reasonNeedsTranslation) {
                indexesToTranslate.add(index + 1);
            }
        }
        if (indexesToTranslate.isEmpty()) {
            return Map.of();
        }

        final String prompt = buildBatchTranslationPrompt(candidates, indexesToTranslate);
        final String responseText = translateToKorean(prompt);
        if (isBlank(responseText)) {
            return Map.of();
        }

        try {
            final JsonNode root = objectMapper.readTree(responseText);
            final JsonNode articlesNode = root.path("articles");
            if (!articlesNode.isArray()) {
                return Map.of();
            }

            final Map<Integer, BatchTranslationDecision> decisions = new LinkedHashMap<>();
            for (JsonNode articleNode : articlesNode) {
                final int index = articleNode.path("index").asInt(-1);
                if (index < 1) {
                    continue;
                }
                decisions.put(index, new BatchTranslationDecision(
                        articleNode.path("summaryKo").asText(""),
                        articleNode.path("reasonKo").asText("")
                ));
            }
            return decisions;
        } catch (Exception exception) {
            log.warn("뉴스 한국어 배치 보정 응답 파싱에 실패했습니다.", exception);
            return Map.of();
        }
    }

    private String buildBatchTranslationPrompt(
            List<IntermediateAnalyzedNewsItem> candidates,
            List<Integer> indexesToTranslate
    ) {
        final StringBuilder prompt = new StringBuilder();
        prompt.append("""
                아래 미국 주식 뉴스 항목들을 한국어 투자 앱용으로 짧게 정리하세요.
                반드시 JSON만 반환하세요.
                형식:
                {
                  "articles": [
                    { "index": 1, "summaryKo": "...", "reasonKo": "..." }
                  ]
                }
                summaryKo는 기사 핵심을 자연스러운 한국어 1~2문장으로,
                reasonKo는 투자 판단 이유를 자연스러운 한국어 1문장으로 작성하세요.
                영어를 그대로 복사하지 말고 한국어로만 작성하세요.
                
                """);
        for (Integer index : indexesToTranslate) {
            final IntermediateAnalyzedNewsItem item = candidates.get(index - 1);
            prompt.append("index: ").append(index).append('\n')
                    .append("headline: ").append(trimForPrompt(item.headline(), 220)).append('\n')
                    .append("summary: ").append(trimForPrompt(item.rawSummary(), 320)).append('\n')
                    .append("draftSummary: ").append(trimForPrompt(item.summary(), 220)).append('\n')
                    .append("draftReason: ").append(trimForPrompt(item.reason(), 220)).append("\n\n");
        }
        return prompt.toString();
    }

    private String translateToKorean(String prompt) {
        final String geminiApiKey = System.getenv("GEMINI_API_KEY");
        if (isBlank(geminiApiKey)) {
            return null;
        }

        try {
            final String uri = "https://generativelanguage.googleapis.com/v1beta/models/"
                    + resolveGeminiTranslationModel()
                    + ":generateContent?key="
                    + encode(geminiApiKey);

            final String requestBody = objectMapper.writeValueAsString(Map.of(
                    "generationConfig", Map.of(
                            "responseMimeType", "application/json"
                    ),
                    "contents", List.of(
                            Map.of("parts", List.of(
                                    Map.of("text", prompt)
                            ))
                    )
            ));

            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .timeout(Duration.ofSeconds(15))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody, StandardCharsets.UTF_8))
                    .build();

            final HttpResponse<String> response = sendGeminiRequestWithRetry(request, "TRANSLATE");
            if (response.statusCode() != 200 || response.body().isBlank()) {
                return null;
            }

            final JsonNode responseRoot = objectMapper.readTree(response.body());
            return responseRoot.path("candidates")
                    .path(0)
                    .path("content")
                    .path("parts")
                    .path(0)
                    .path("text")
                    .asText("")
                    .trim();
        } catch (Exception exception) {
            log.warn("뉴스 한국어 보정에 실패했습니다.", exception);
            return null;
        }
    }

    private boolean containsWholeWord(String text, String keyword) {
        if (isBlank(keyword)) {
            return false;
        }
        final Pattern pattern = Pattern.compile(
                "(?<![a-z0-9])" + Pattern.quote(normalizeText(keyword)) + "(?![a-z0-9])"
        );
        return pattern.matcher(text).find();
    }

    private boolean containsKeyword(String text, String keyword) {
        final boolean asciiKeyword = keyword.chars().allMatch(character ->
                character < 128
        );
        return asciiKeyword ? containsWholeWord(text, keyword) : text.contains(keyword);
    }

    private String normalizeHeadline(String value) {
        return normalizeText(value).replaceAll("[^a-z0-9가-힣 ]", "");
    }

    private String normalizeText(String value) {
        return defaultIfBlank(value, "")
                .toLowerCase(Locale.ROOT)
                .replaceAll("\\s+", " ")
                .trim();
    }

    private String canonicalizeUrl(String value) {
        final String url = defaultIfBlank(value, "").trim();
        final int queryIndex = url.indexOf('?');
        return queryIndex >= 0 ? url.substring(0, queryIndex) : url;
    }

    private String sha256(String value) {
        try {
            final MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception exception) {
            throw new IllegalStateException("뉴스 중복 제거 해시를 생성하지 못했습니다.", exception);
        }
    }

    private String buildAnalysisBatchHash(List<RawNewsItem> candidates) {
        final String displayDate = candidates.stream()
                .map(RawNewsItem::publishedAt)
                .filter(publishedAt -> publishedAt != null)
                .map(publishedAt -> publishedAt.atZoneSameInstant(DAILY_NEWS_ZONE).toLocalDate())
                .max(LocalDate::compareTo)
                .orElse(LocalDate.now(DAILY_NEWS_ZONE))
                .toString();
        final String contentHashes = candidates.stream()
                .map(RawNewsItem::contentHash)
                .sorted()
                .reduce((left, right) -> left + "|" + right)
                .orElse("");
        return sha256(displayDate + "|" + contentHashes);
    }

    private BigDecimal decimal(double value) {
        return BigDecimal.valueOf(value).setScale(4, RoundingMode.HALF_UP);
    }

    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(value, max));
    }

    private int zeroIfNull(Integer value) {
        return value == null ? 0 : value;
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private String defaultIfBlank(String value, String fallback) {
        return isBlank(value) ? fallback : value;
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private String resolveGeminiModel() {
        return defaultIfBlank(System.getenv("GEMINI_MODEL"), DEFAULT_GEMINI_MODEL);
    }

    private String resolveGeminiTranslationModel() {
        return defaultIfBlank(
                System.getenv("GEMINI_TRANSLATION_MODEL"),
                DEFAULT_GEMINI_TRANSLATION_MODEL
        );
    }

    private record RawNewsItem(
            String newsId,
            String headline,
            String summary,
            String sourceName,
            String url,
            OffsetDateTime publishedAt,
            int keywordScore,
            boolean hardNegative,
            String contentHash,
            int heuristicRelevanceScore
    ) {
        RawNewsItem withHeuristicRelevance(int relevanceScore) {
            return new RawNewsItem(
                    newsId,
                    headline,
                    summary,
                    sourceName,
                    url,
                    publishedAt,
                    keywordScore,
                    hardNegative,
                    contentHash,
                    relevanceScore
            );
        }
    }

    private record KeywordResult(int score, boolean hardNegative) {
    }

    private record GeminiArticleDecision(
            int sentimentScore,
            int relevanceScore,
            String impactLevel,
            String summaryKo,
            String reason
    ) {
    }

    private record GeminiBatchResult(
            Map<Integer, GeminiArticleDecision> decisions,
            String overallSummary,
            String model
    ) {
    }

    public record AnalyzedNewsItem(
            String newsId,
            String symbol,
            String headline,
            String summary,
            String sourceName,
            String newsUrl,
            OffsetDateTime newsPublishedAt,
            String sentimentLabel,
            int sentimentScore,
            int keywordScore,
            int relevanceScore,
            String impactLevel,
            String reason,
            BigDecimal recencyWeight,
            BigDecimal impactWeight,
            BigDecimal weightedScore,
            String contentHash,
            String analysisBatchHash
    ) {
    }

    private record IntermediateAnalyzedNewsItem(
            String newsId,
            String symbol,
            String headline,
            String summary,
            String sourceName,
            String newsUrl,
            OffsetDateTime newsPublishedAt,
            String sentimentLabel,
            int sentimentScore,
            int keywordScore,
            int relevanceScore,
            String impactLevel,
            String reason,
            BigDecimal recencyWeight,
            BigDecimal impactWeight,
            BigDecimal weightedScore,
            String contentHash,
            String analysisBatchHash,
            String rawSummary
    ) {
    }

    private record BatchTranslationDecision(
            String summaryKo,
            String reasonKo
    ) {
    }

    public record NewsSentimentResult(
            int score,
            String label,
            String summary,
            List<AnalyzedNewsItem> relatedNews,
            String llmModel,
            int weightedSentimentScore,
            boolean hardNegativeOverride,
            String hardNegativeCategory,
            int analysisConfidence,
            boolean cacheReused,
            boolean replaceCache
    ) {
        public NewsSentimentResult(
                int score,
                String label,
                String summary,
                List<AnalyzedNewsItem> relatedNews,
                String llmModel,
                int weightedSentimentScore,
                boolean hardNegativeOverride,
                int analysisConfidence,
                boolean cacheReused,
                boolean replaceCache
        ) {
            this(
                    score,
                    label,
                    summary,
                    relatedNews,
                    llmModel,
                    weightedSentimentScore,
                    hardNegativeOverride,
                    "NONE",
                    analysisConfidence,
                    cacheReused,
                    replaceCache
            );
        }

        static NewsSentimentResult unavailable() {
            return new NewsSentimentResult(
                    9,
                    "NEUTRAL",
                    "뉴스 감성 분석 데이터를 가져오지 못해 중립 점수로 처리했습니다.",
                    List.of(),
                    null,
                    0,
                    false,
                    "NONE",
                    0,
                    false,
                    false
            );
        }

        static NewsSentimentResult empty() {
            return new NewsSentimentResult(
                    9,
                    "NEUTRAL",
                    "한국시간 기준 표시 가능한 관련 뉴스가 없어 뉴스 점수를 중립으로 처리했습니다.",
                    List.of(),
                    null,
                    0,
                    false,
                    "NONE",
                    0,
                    false,
                    false
            );
        }

        static NewsSentimentResult geminiUnavailable() {
            return new NewsSentimentResult(
                    9,
                    "NEUTRAL",
                    "Gemini 기사 분석을 완료하지 못해 뉴스 점수를 중립으로 처리했습니다.",
                    List.of(),
                    null,
                    0,
                    false,
                    "NONE",
                    0,
                    false,
                    false
            );
        }
    }
}
