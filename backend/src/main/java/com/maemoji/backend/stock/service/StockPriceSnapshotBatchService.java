package com.maemoji.backend.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.config.PriceSnapshotBatchProperties;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.domain.StockPriceSnapshotRecord;
import com.maemoji.backend.stock.dto.PriceSnapshotBatchResult;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

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
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class StockPriceSnapshotBatchService {

    private static final Logger log = LoggerFactory.getLogger(StockPriceSnapshotBatchService.class);
    private static final ZoneId SNAPSHOT_ZONE = ZoneId.of("Asia/Seoul");
    private static final String SOURCE = "FINNHUB";
    private static final String FMP_MODEL_SOURCE = "FINNHUB_FMP";

    private final StockPriceSnapshotMapper stockPriceSnapshotMapper;
    private final PriceSnapshotBatchProperties properties;
    private final StockPriceReturnCalculator priceReturnCalculator;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public StockPriceSnapshotBatchService(
            StockPriceSnapshotMapper stockPriceSnapshotMapper,
            PriceSnapshotBatchProperties properties,
            StockPriceReturnCalculator priceReturnCalculator,
            ObjectMapper objectMapper
    ) {
        this.stockPriceSnapshotMapper = stockPriceSnapshotMapper;
        this.properties = properties;
        this.priceReturnCalculator = priceReturnCalculator;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Scheduled(cron = "${maemoji.batch.price-snapshots.cron}")
    public void syncDailySnapshots() {
        if (!properties.isEnabled()) {
            return;
        }
        syncSnapshots(null, true);
    }

    public PriceSnapshotBatchResult syncSnapshots(Integer limit, boolean usedScheduler) {
        final String apiKey = System.getenv("FINNHUB_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("FINNHUB_API_KEY 환경변수가 필요합니다.");
        }

        final int effectiveLimit = limit == null || limit <= 0
                ? properties.getDefaultLimit()
                : limit;
        final String fmpApiKey = System.getenv("FMP_API_KEY");
        final List<Stock> stocks = stockPriceSnapshotMapper.findActiveStocksForSnapshot(effectiveLimit);
        final Set<Long> portfolioStockIds =
                new HashSet<>(stockPriceSnapshotMapper.findActivePortfolioStockIds());
        final LocalDate snapshotDate = LocalDate.now(SNAPSHOT_ZONE);
        final long startedAtNanos = System.nanoTime();

        int savedCount = 0;
        int failedCount = 0;

        log.info(
                "가격 스냅샷 배치를 시작합니다. snapshotDate={}, requested={}, portfolioStocks={}, requestMode=QUOTE_ALL_METRIC_PORTFOLIO",
                snapshotDate,
                stocks.size(),
                portfolioStockIds.size()
        );
        for (int index = 0; index < stocks.size(); index++) {
            final Stock stock = stocks.get(index);
            try {
                final String symbol = stock.getFinnhubSymbol() == null || stock.getFinnhubSymbol().isBlank()
                        ? stock.getTicker()
                        : stock.getFinnhubSymbol();
                final boolean fetchMetrics = portfolioStockIds.contains(stock.getId());
                final StockPriceSnapshotRecord previousSnapshot =
                        stockPriceSnapshotMapper.findLatestSnapshotByStockId(stock.getId());
                final SnapshotData snapshotData = fetchSnapshotData(
                        symbol,
                        apiKey,
                        fmpApiKey,
                        fetchMetrics
                );
                if (snapshotData.currentPrice() == null) {
                    throw new IllegalStateException("Finnhub 현재가가 비어 있습니다. symbol=" + symbol);
                }
                final BigDecimal currentPrice = decimalOrNull(snapshotData.currentPrice());
                final BigDecimal marketCap = firstNonNull(
                        decimalOrNull(snapshotData.marketCap()),
                        previousSnapshot == null ? null : previousSnapshot.getMarketCap()
                );
                final BigDecimal perValue = firstNonNull(
                        decimalOrNull(snapshotData.perValue()),
                        previousSnapshot == null ? null : previousSnapshot.getPerValue()
                );
                final BigDecimal epsTtm = firstNonNull(
                        decimalOrNull(snapshotData.epsTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getEpsTtm()
                );
                final BigDecimal revenueGrowthYoy = firstNonNull(
                        decimalOrNull(snapshotData.revenueGrowthYoy()),
                        previousSnapshot == null ? null : previousSnapshot.getRevenueGrowthYoy()
                );
                final BigDecimal operatingMarginTtm = firstNonNull(
                        decimalOrNull(snapshotData.operatingMarginTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getOperatingMarginTtm()
                );
                final BigDecimal roeTtm = firstNonNull(
                        decimalOrNull(snapshotData.roeTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getRoeTtm()
                );
                final BigDecimal debtToEquityTtm = firstNonNull(
                        decimalOrNull(snapshotData.debtToEquityTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getDebtToEquityTtm()
                );
                final PriceReturns priceReturns = calculateReturns(
                        stock.getId(),
                        snapshotDate,
                        currentPrice
                );
                stockPriceSnapshotMapper.upsertPriceSnapshot(
                        stock.getId(),
                        snapshotDate,
                        currentPrice,
                        priceReturns.changeRate1d(),
                        priceReturns.changeRate7d(),
                        priceReturns.changeRate30d(),
                        marketCap,
                        perValue,
                        epsTtm,
                        revenueGrowthYoy,
                        operatingMarginTtm,
                        roeTtm,
                        debtToEquityTtm,
                        snapshotData.hasFmpFundamentals() ? FMP_MODEL_SOURCE : SOURCE
                );
                savedCount++;
            } catch (FinnhubAuthenticationException exception) {
                log.error("Finnhub 인증에 실패해 가격 배치를 중단합니다. API 키를 확인해주세요.");
                throw exception;
            } catch (Exception exception) {
                failedCount++;
                log.warn("가격 스냅샷 적재에 실패했습니다. stockId={}, ticker={}", stock.getId(), stock.getTicker(), exception);
            } finally {
                sleep(properties.getDelayMillis());
            }

            final int processedCount = index + 1;
            if (processedCount % 25 == 0 || processedCount == stocks.size()) {
                log.info(
                        "가격 스냅샷 배치 진행 중입니다. processed={}/{}, saved={}, failed={}, elapsedSeconds={}",
                        processedCount,
                        stocks.size(),
                        savedCount,
                        failedCount,
                        Duration.ofNanos(System.nanoTime() - startedAtNanos).toSeconds()
                );
            }
        }

        log.info("가격 스냅샷 배치가 완료되었습니다. saved={}, failed={}", savedCount, failedCount);
        return new PriceSnapshotBatchResult(
                snapshotDate,
                stocks.size(),
                savedCount,
                failedCount,
                usedScheduler
        );
    }

    private SnapshotData fetchSnapshotData(
            String symbol,
            String apiKey,
            String fmpApiKey,
            boolean fetchMetrics
    ) throws Exception {
        final JsonNode quote = getJson(
                "https://finnhub.io/api/v1/quote?symbol=" + encode(symbol) + "&token=" + encode(apiKey)
        );
        final JsonNode metrics = fetchMetrics
                ? getJsonOrNull(
                        "https://finnhub.io/api/v1/stock/metric?symbol="
                                + encode(symbol)
                                + "&metric=all&token="
                                + encode(apiKey),
                        symbol
                )
                : null;
        final JsonNode keyMetrics = fetchMetrics && hasText(fmpApiKey)
                ? getJsonOrNull(
                        "https://financialmodelingprep.com/stable/key-metrics-ttm?symbol="
                                + encode(symbol)
                                + "&apikey="
                                + encode(fmpApiKey),
                        symbol
                )
                : null;
        final JsonNode ratios = fetchMetrics && hasText(fmpApiKey)
                ? getJsonOrNull(
                        "https://financialmodelingprep.com/stable/ratios-ttm?symbol="
                                + encode(symbol)
                                + "&apikey="
                                + encode(fmpApiKey),
                        symbol
                )
                : null;
        final JsonNode incomeGrowth = fetchMetrics && hasText(fmpApiKey)
                ? getJsonOrNull(
                        "https://financialmodelingprep.com/stable/income-statement-growth?symbol="
                                + encode(symbol)
                                + "&limit=1&apikey="
                                + encode(fmpApiKey),
                        symbol
                )
                : null;
        final JsonNode keyMetricNode = firstValueNode(keyMetrics);
        final JsonNode ratioNode = firstValueNode(ratios);
        final JsonNode growthNode = firstValueNode(incomeGrowth);

        return new SnapshotData(
                readPositiveDouble(quote, "c"),
                firstNonNull(
                        readNullableDouble(keyMetricNode, "marketCap"),
                        readNullableDouble(metrics == null ? null : metrics.path("metric"), "marketCapitalization")
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "priceToEarningsRatioTTM"),
                        readNullableDouble(metrics == null ? null : metrics.path("metric"), "peTTM")
                ),
                readNullableDouble(ratioNode, "netIncomePerShareTTM"),
                readNullableDouble(growthNode, "growthRevenue"),
                readNullableDouble(ratioNode, "operatingProfitMarginTTM"),
                readNullableDouble(keyMetricNode, "returnOnEquityTTM"),
                readNullableDouble(ratioNode, "debtToEquityRatioTTM")
        );
    }

    private JsonNode firstValueNode(JsonNode root) {
        if (root == null || root.isMissingNode() || root.isNull()) {
            return null;
        }
        if (root.isArray()) {
            return root.isEmpty() ? null : root.get(0);
        }
        if (root.isObject() && root.has("symbol")) {
            return root;
        }
        final JsonNode value = root.path("value");
        if (!value.isArray() || value.isEmpty()) {
            return null;
        }
        return value.get(0);
    }

    private PriceReturns calculateReturns(
            Long stockId,
            LocalDate snapshotDate,
            BigDecimal currentPrice
    ) {
        final BigDecimal previousPrice =
                stockPriceSnapshotMapper.findPreviousPrice(stockId, snapshotDate);
        final BigDecimal sevenDayPrice = stockPriceSnapshotMapper.findReferencePrice(
                stockId,
                snapshotDate.minusDays(7),
                snapshotDate.minusDays(14)
        );
        final BigDecimal thirtyDayPrice = stockPriceSnapshotMapper.findReferencePrice(
                stockId,
                snapshotDate.minusDays(30),
                snapshotDate.minusDays(40)
        );

        return new PriceReturns(
                priceReturnCalculator.calculate(currentPrice, previousPrice),
                priceReturnCalculator.calculate(currentPrice, sevenDayPrice),
                priceReturnCalculator.calculate(currentPrice, thirtyDayPrice)
        );
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
        if (response.statusCode() == 401 || response.statusCode() == 403) {
            throw new FinnhubAuthenticationException(response.statusCode());
        }
        if (response.statusCode() != 200 || response.body().isBlank()) {
            throw new IllegalStateException("Finnhub 응답이 비정상입니다. status=" + response.statusCode());
        }
        return objectMapper.readTree(response.body());
    }

    private JsonNode getJsonOrNull(String uri, String symbol) {
        try {
            return getJson(uri);
        } catch (Exception exception) {
            log.info(
                    "선택형 Finnhub 지표 데이터는 건너뜁니다. symbol={}, reason={}",
                    symbol,
                    exception.getMessage()
            );
            return null;
        }
    }

    private Double readPositiveDouble(JsonNode node, String fieldName) {
        final double value = node.path(fieldName).asDouble(0);
        return value > 0 ? value : null;
    }

    private Double readNullableDouble(JsonNode node, String fieldName) {
        if (node == null || node.isMissingNode() || node.path(fieldName).isMissingNode() || node.path(fieldName).isNull()) {
            return null;
        }
        final double value = node.path(fieldName).asDouble(Double.NaN);
        return Double.isNaN(value) ? null : value;
    }

    private Double firstNonNull(Double primary, Double fallback) {
        return primary == null ? fallback : primary;
    }

    private BigDecimal decimalOrNull(Double value) {
        return value == null
                ? null
                : BigDecimal.valueOf(value).setScale(4, RoundingMode.HALF_UP);
    }

    private BigDecimal firstNonNull(BigDecimal primary, BigDecimal fallback) {
        return primary == null ? fallback : primary;
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private void sleep(int millis) {
        if (millis <= 0) {
            return;
        }
        try {
            Thread.sleep(millis);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
        }
    }

    private record SnapshotData(
            Double currentPrice,
            Double marketCap,
            Double perValue,
            Double epsTtm,
            Double revenueGrowthYoy,
            Double operatingMarginTtm,
            Double roeTtm,
            Double debtToEquityTtm
    ) {
        boolean hasFmpFundamentals() {
            return epsTtm != null
                    || revenueGrowthYoy != null
                    || operatingMarginTtm != null
                    || roeTtm != null
                    || debtToEquityTtm != null;
        }
    }

    private record PriceReturns(
            BigDecimal changeRate1d,
            BigDecimal changeRate7d,
            BigDecimal changeRate30d
    ) {
    }

    private static final class FinnhubAuthenticationException extends RuntimeException {
        private FinnhubAuthenticationException(int statusCode) {
            super("Finnhub 인증 실패: status=" + statusCode);
        }
    }
}
