package com.maemoji.backend.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.config.PriceSnapshotBatchProperties;
import com.maemoji.backend.stock.domain.Stock;
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
import java.util.List;

@Service
public class StockPriceSnapshotBatchService {

    private static final Logger log = LoggerFactory.getLogger(StockPriceSnapshotBatchService.class);
    private static final ZoneId SNAPSHOT_ZONE = ZoneId.of("Asia/Seoul");
    private static final String SOURCE = "FINNHUB";

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
        final List<Stock> stocks = stockPriceSnapshotMapper.findActiveStocksForSnapshot(effectiveLimit);
        final LocalDate snapshotDate = LocalDate.now(SNAPSHOT_ZONE);

        int savedCount = 0;
        int failedCount = 0;

        log.info("가격 스냅샷 배치를 시작합니다. snapshotDate={}, requested={}", snapshotDate, stocks.size());
        for (Stock stock : stocks) {
            try {
                final String symbol = stock.getFinnhubSymbol() == null || stock.getFinnhubSymbol().isBlank()
                        ? stock.getTicker()
                        : stock.getFinnhubSymbol();
                final SnapshotData snapshotData = fetchSnapshotData(symbol, apiKey);
                if (snapshotData.currentPrice() == null) {
                    throw new IllegalStateException("Finnhub 현재가가 비어 있습니다. symbol=" + symbol);
                }
                final BigDecimal currentPrice = decimalOrNull(snapshotData.currentPrice());
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
                        decimalOrNull(snapshotData.marketCap()),
                        decimalOrNull(snapshotData.perValue()),
                        SOURCE
                );
                savedCount++;
                sleep(properties.getDelayMillis());
            } catch (Exception exception) {
                failedCount++;
                log.warn("가격 스냅샷 적재에 실패했습니다. stockId={}, ticker={}", stock.getId(), stock.getTicker(), exception);
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

    private SnapshotData fetchSnapshotData(String symbol, String apiKey) throws Exception {
        final JsonNode quote = getJson(
                "https://finnhub.io/api/v1/quote?symbol=" + encode(symbol) + "&token=" + encode(apiKey)
        );
        final JsonNode metrics = getJsonOrNull(
                "https://finnhub.io/api/v1/stock/metric?symbol="
                        + encode(symbol)
                        + "&metric=all&token="
                        + encode(apiKey)
        );

        return new SnapshotData(
                readPositiveDouble(quote, "c"),
                readNullableDouble(metrics == null ? null : metrics.path("metric"), "marketCapitalization"),
                readNullableDouble(metrics == null ? null : metrics.path("metric"), "peTTM")
        );
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
        if (response.statusCode() != 200 || response.body().isBlank()) {
            throw new IllegalStateException("Finnhub 응답이 비정상입니다. status=" + response.statusCode());
        }
        return objectMapper.readTree(response.body());
    }

    private JsonNode getJsonOrNull(String uri) {
        try {
            return getJson(uri);
        } catch (Exception exception) {
            log.info("선택형 Finnhub 데이터는 건너뜁니다. uri={}", uri, exception);
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

    private BigDecimal decimalOrNull(Double value) {
        return value == null
                ? null
                : BigDecimal.valueOf(value).setScale(4, RoundingMode.HALF_UP);
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
            Double perValue
    ) {
    }

    private record PriceReturns(
            BigDecimal changeRate1d,
            BigDecimal changeRate7d,
            BigDecimal changeRate30d
    ) {
    }
}
