package com.maemoji.backend.stock.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.config.TopStockSyncProperties;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.dto.TopStockSyncResult;
import com.maemoji.backend.stock.mapper.StockMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class TopStockSyncService {

    private static final Logger log = LoggerFactory.getLogger(TopStockSyncService.class);

    private static final TypeReference<Map<String, Object>> MAP_TYPE =
            new TypeReference<>() {
            };

    private static final Pattern STOCK_ANALYSIS_ROW_PATTERN = Pattern.compile(
            "(?s)<tr class=\"svelte-1ro3niy\">.*?"
                    + "<td class=\"svelte-1ro3niy\">(\\d+)</td>.*?"
                    + "<td class=\"sym svelte-1ro3niy\"><!----><a href=\"/stocks/[^/]+/\">([A-Z0-9.\\-]+)</a>.*?"
                    + "<td class=\"slw svelte-1ro3niy\">([^<]+)</td>.*?"
                    + "<td class=\"svelte-1ro3niy\">([0-9.,]+[TBM])</td>"
    );

    private final StockMapper stockMapper;
    private final StockService stockService;
    private final TopStockSyncProperties properties;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public TopStockSyncService(
            StockMapper stockMapper,
            StockService stockService,
            TopStockSyncProperties properties,
            ObjectMapper objectMapper
    ) {
        this.stockMapper = stockMapper;
        this.stockService = stockService;
        this.properties = properties;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    /// 운영에서는 매일 정해진 시각에 기존 종목 마스터를 최신 정보로 갱신합니다.
    @Scheduled(cron = "${maemoji.batch.top-stocks.cron}")
    public void syncTopStocksOnSchedule() {
        if (!properties.isEnabled()) {
            return;
        }

        refreshExistingStocks(true, properties.getTargetCount());
    }

    /// 수동 실행 시에는 현재 DB에 들어있는 종목 마스터를 순서대로 갱신합니다.
    public TopStockSyncResult refreshExistingStocks(boolean scheduledRun, Integer limitOverride) {
        final String apiKey = System.getenv("FINNHUB_API_KEY");

        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("FINNHUB_API_KEY 환경변수가 필요합니다.");
        }

        final List<Stock> activeStocks = stockMapper.findActiveStocksForRefresh();
        final int limit = limitOverride != null && limitOverride > 0
                ? Math.min(limitOverride, activeStocks.size())
                : Math.min(properties.getTargetCount(), activeStocks.size());

        log.info("기존 종목 마스터 갱신을 시작합니다. total={}, target={}", activeStocks.size(), limit);

        int syncedCount = 0;

        for (Stock stock : activeStocks.stream().limit(limit).toList()) {
            final String symbol = stock.getFinnhubSymbol() == null || stock.getFinnhubSymbol().isBlank()
                    ? stock.getTicker()
                    : stock.getFinnhubSymbol();
            final Map<String, Object> profile = fetchFinnhubCompanyProfile(symbol, apiKey);

            final String updatedNameEn = firstNonBlank(profile.get("name"), stock.getNameEn());
            final String updatedExchange = normalizeFinnhubExchange(
                    firstNonBlank(profile.get("exchange"), stock.getExchangeCode()),
                    stock.getExchangeCode()
            );
            final String updatedLogoUrl = firstNonBlank(profile.get("logo"), stock.getLogoUrl());
            final StockService.NormalizedStockFields normalizedFields = stockService.normalizeStockFields(
                    stock.getTicker(),
                    stock.getNameKo(),
                    updatedNameEn
            );

            stockMapper.updateStockMaster(
                    stock.getId(),
                    updatedExchange,
                    symbol,
                    stock.getNameKo(),
                    updatedNameEn,
                    normalizedFields.tickerNormalized(),
                    normalizedFields.nameKoNormalized(),
                    normalizedFields.nameEnNormalized(),
                    normalizedFields.searchText(),
                    updatedLogoUrl,
                    stock.getMarketType()
            );
            syncedCount++;

            sleepBetweenCalls();
        }

        log.info("기존 종목 마스터 갱신이 완료되었습니다. synced={}", syncedCount);

        return new TopStockSyncResult(
                activeStocks.size(),
                limit,
                syncedCount,
                scheduledRun
        );
    }

    /// 초기 적재는 시총 상위 종목이 먼저 들어오도록 FMP bulk profile을 기준으로 구성합니다.
    public TopStockSyncResult importTopStocksFromApi(Integer limitOverride) {
        final String apiKey = System.getenv("FINNHUB_API_KEY");

        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("FINNHUB_API_KEY 환경변수가 필요합니다.");
        }

        log.info("시총 상위 종목 bootstrap 요청을 받았습니다. limit={}", limitOverride);

        final List<BootstrapStockCandidateWithMarketCap> stockUniverse =
                fetchTopUsStocksByMarketCapFromPublicRanking();

        if (stockUniverse.isEmpty()) {
            throw new IllegalStateException(
                    "공개 시총 랭킹 페이지에서 상위 종목 데이터를 가져오지 못했습니다."
            );
        }

        final int targetCount = limitOverride != null && limitOverride > 0
                ? Math.min(limitOverride, stockUniverse.size())
                : Math.min(properties.getTargetCount(), stockUniverse.size());
        final List<BootstrapStockCandidateWithMarketCap> selectedCandidates = stockUniverse.stream()
                .limit(targetCount)
                .toList();

        log.info(
                "시총 상위 종목 마스터 적재를 시작합니다. totalUniverse={}, target={}",
                stockUniverse.size(),
                selectedCandidates.size()
        );

        int syncedCount = 0;

        for (BootstrapStockCandidateWithMarketCap rankedCandidate : selectedCandidates) {
            final BootstrapStockCandidate candidate = enrichRankedCandidate(rankedCandidate, apiKey);
            final StockService.NormalizedStockFields normalizedFields = stockService.normalizeStockFields(
                    candidate.ticker(),
                    null,
                    candidate.nameEn()
            );
            final Long existingId = stockMapper.findStockIdByFinnhubSymbol(candidate.finnhubSymbol());

            if (existingId != null) {
                stockMapper.updateStockMaster(
                        existingId,
                        candidate.exchangeCode(),
                        candidate.finnhubSymbol(),
                        null,
                        candidate.nameEn(),
                        normalizedFields.tickerNormalized(),
                        normalizedFields.nameKoNormalized(),
                        normalizedFields.nameEnNormalized(),
                        normalizedFields.searchText(),
                        candidate.logoUrl(),
                        candidate.marketType()
                );
            } else {
                stockMapper.upsertStockMaster(
                        candidate.ticker(),
                        candidate.exchangeCode(),
                        candidate.finnhubSymbol(),
                        null,
                        candidate.nameEn(),
                        normalizedFields.tickerNormalized(),
                        normalizedFields.nameKoNormalized(),
                        normalizedFields.nameEnNormalized(),
                        normalizedFields.searchText(),
                        candidate.logoUrl(),
                        candidate.marketType()
                );
            }

            syncedCount++;
            sleepBetweenCalls();

            if (syncedCount == 1 || syncedCount % 25 == 0 || syncedCount == selectedCandidates.size()) {
                log.info("시총 상위 종목 적재 진행중입니다. progress={}/{}", syncedCount, selectedCandidates.size());
            }
        }

        log.info("시총 상위 종목 마스터 적재가 완료되었습니다. synced={}", syncedCount);

        return new TopStockSyncResult(
                stockUniverse.size(),
                selectedCandidates.size(),
                syncedCount,
                false
        );
    }

    private List<BootstrapStockCandidateWithMarketCap> fetchTopUsStocksByMarketCapFromPublicRanking() {
        try {
            final String uri = "https://stockanalysis.com/list/biggest-companies/";
            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .timeout(Duration.ofSeconds(30))
                    .GET()
                    .build();

            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );

            if (response.statusCode() != 200) {
                log.warn("공개 시총 랭킹 페이지 응답이 비정상입니다. status={}", response.statusCode());
                return List.of();
            }

            if (response.body().isBlank()) {
                log.warn("공개 시총 랭킹 페이지 응답 본문이 비어 있습니다.");
                return List.of();
            }

            final List<BootstrapStockCandidateWithMarketCap> rankedStocks = parseStockAnalysisRows(response.body());

            if (rankedStocks.isEmpty()) {
                log.warn("공개 시총 랭킹 페이지에서 파싱된 종목이 없습니다.");
                return List.of();
            }

            log.info("시총 랭킹 페이지 파싱이 완료되었습니다. parsed={}", rankedStocks.size());
            return rankedStocks;
        } catch (Exception exception) {
            throw new IllegalStateException("공개 시총 랭킹 기반 초기 적재에 실패했습니다.", exception);
        }
    }

    private BootstrapStockCandidate enrichRankedCandidate(
            BootstrapStockCandidateWithMarketCap rankedCandidate,
            String apiKey
    ) {
        try {
            final Map<String, Object> profile = fetchFinnhubCompanyProfile(rankedCandidate.finnhubSymbol(), apiKey);
            final String exchangeCode = normalizeFinnhubExchange(
                    firstNonBlank(profile.get("exchange")),
                    inferFallbackExchangeFromTicker(rankedCandidate.finnhubSymbol())
            );

            return new BootstrapStockCandidate(
                    rankedCandidate.ticker(),
                    exchangeCode,
                    rankedCandidate.finnhubSymbol(),
                    firstNonBlank(profile.get("name"), rankedCandidate.nameEn()),
                    firstNonBlank(profile.get("logo")),
                    "COMMON_STOCK"
            );
        } catch (Exception exception) {
            log.warn("시총 상위 종목 보강에 실패했습니다. symbol={}", rankedCandidate.finnhubSymbol(), exception);
            return new BootstrapStockCandidate(
                    rankedCandidate.ticker(),
                    inferFallbackExchangeFromTicker(rankedCandidate.finnhubSymbol()),
                    rankedCandidate.finnhubSymbol(),
                    rankedCandidate.nameEn(),
                    "",
                    "COMMON_STOCK"
            );
        }
    }

    private List<BootstrapStockCandidateWithMarketCap> parseStockAnalysisRows(String html) {
        final List<BootstrapStockCandidateWithMarketCap> rankedStocks = new ArrayList<>();
        final Matcher matcher = STOCK_ANALYSIS_ROW_PATTERN.matcher(html);

        while (matcher.find()) {
            final String ticker = matcher.group(2).trim();
            final String nameEn = decodeHtmlEntities(matcher.group(3).trim());
            final double marketCap = parseMarketCap(matcher.group(4).trim());

            if (ticker.isEmpty()
                    || nameEn.isEmpty()
                    || marketCap <= 0
                    || !isSearchEligibleSecurity(ticker, nameEn)) {
                continue;
            }

            rankedStocks.add(new BootstrapStockCandidateWithMarketCap(
                    ticker,
                    "",
                    ticker,
                    nameEn,
                    "",
                    "COMMON_STOCK",
                    marketCap
            ));
        }

        return rankedStocks;
    }

    private String decodeHtmlEntities(String value) {
        return value.replace("&amp;", "&")
                .replace("&#39;", "'")
                .replace("&quot;", "\"")
                .replace("&nbsp;", " ");
    }

    private double parseMarketCap(String text) {
        if (text.length() < 2) {
            return 0;
        }

        final char suffix = Character.toUpperCase(text.charAt(text.length() - 1));
        final double baseValue;
        try {
            baseValue = Double.parseDouble(text.substring(0, text.length() - 1).replace(",", ""));
        } catch (NumberFormatException exception) {
            return 0;
        }

        return switch (suffix) {
            case 'T' -> baseValue * 1_000_000_000_000d;
            case 'B' -> baseValue * 1_000_000_000d;
            case 'M' -> baseValue * 1_000_000d;
            default -> 0;
        };
    }

    private String inferFallbackExchangeFromTicker(String ticker) {
        return ticker.contains(".") ? "NYSE" : "NASDAQ";
    }

    private Map<String, Object> fetchFinnhubCompanyProfile(String symbol, String apiKey) {
        try {
            final String uri = "https://finnhub.io/api/v1/stock/profile2?symbol="
                    + encode(symbol)
                    + "&token="
                    + encode(apiKey);

            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .timeout(Duration.ofSeconds(20))
                    .GET()
                    .build();

            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );

            if (response.statusCode() != 200 || response.body().isBlank()) {
                return Map.of();
            }

            return objectMapper.readValue(response.body(), MAP_TYPE);
        } catch (Exception exception) {
            throw new IllegalStateException("Finnhub 회사 정보 조회에 실패했습니다.", exception);
        }
    }

    private String normalizeFinnhubExchange(String exchange, String fallbackExchangeCode) {
        if (exchange == null || exchange.isBlank()) {
            return fallbackExchangeCode;
        }

        final String upperExchange = exchange.toUpperCase(Locale.ROOT);

        if (upperExchange.contains("NASDAQ")) {
            return "NASDAQ";
        }

        if (upperExchange.contains("NEW YORK STOCK EXCHANGE") || upperExchange.contains("NYSE")) {
            return "NYSE";
        }

        if (upperExchange.contains("AMERICAN STOCK EXCHANGE") || upperExchange.contains("NYSE AMERICAN")) {
            return "NYSE_AMERICAN";
        }

        if (upperExchange.contains("NYSE ARCA")) {
            return "NYSE_ARCA";
        }

        if (upperExchange.contains("BATS")) {
            return "BATS";
        }

        if (upperExchange.contains("IEX")) {
            return "IEX";
        }

        return fallbackExchangeCode;
    }

    // 검색 노이즈가 큰 워런트, 권리주, 유닛, 테스트 종목은 초기 검색 마스터에서 제외합니다.
    private boolean isSearchEligibleSecurity(String ticker, String nameEn) {
        final String upperTicker = ticker.toUpperCase(Locale.ROOT);
        final String upperName = nameEn.toUpperCase(Locale.ROOT);

        if (upperTicker.contains("$")) {
            return false;
        }

        return !upperName.contains(" WARRANT")
                && !upperName.contains(" RIGHT")
                && !upperName.contains(" UNIT")
                && !upperName.contains(" TEST ")
                && !upperName.contains(" NEXTSHARES");
    }

    private String firstNonBlank(Object... candidates) {
        for (Object candidate : candidates) {
            if (candidate == null) {
                continue;
            }

            final String value = candidate.toString().trim();
            if (!value.isEmpty()) {
                return value;
            }
        }

        return "";
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private void sleepBetweenCalls() {
        final int delayMillis = Math.max(properties.getDelayMillis(), 0);

        if (delayMillis == 0) {
            return;
        }

        try {
            Thread.sleep(delayMillis);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("종목 마스터 갱신 대기 중 인터럽트가 발생했습니다.", exception);
        }
    }

    private record BootstrapStockCandidate(
            String ticker,
            String exchangeCode,
            String finnhubSymbol,
            String nameEn,
            String logoUrl,
            String marketType
    ) {
    }

    private record BootstrapStockCandidateWithMarketCap(
            String ticker,
            String exchangeCode,
            String finnhubSymbol,
            String nameEn,
            String logoUrl,
            String marketType,
            double marketCap
    ) {
    }
}
