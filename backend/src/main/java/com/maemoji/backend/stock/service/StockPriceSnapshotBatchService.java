package com.maemoji.backend.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.config.PriceSnapshotBatchProperties;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.domain.StockPriceSnapshotRecord;
import com.maemoji.backend.stock.dto.PriceHistoryBackfillResult;
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
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class StockPriceSnapshotBatchService {

    private static final Logger log = LoggerFactory.getLogger(StockPriceSnapshotBatchService.class);
    private static final ZoneId SNAPSHOT_ZONE = ZoneId.of("Asia/Seoul");
    private static final String SOURCE = "FINNHUB";
    private static final String FMP_MODEL_SOURCE = "FINNHUB_FMP";
    private static final String FMP_EMPTY_SOURCE = "FINNHUB_FMP_EMPTY";
    private static final int MINIMUM_CORE_FUNDAMENTAL_FIELDS = 4;
    private static final int EXTENDED_RETRY_LOOKBACK_DAYS = 120;

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
        final SelectedStocks selectedStocks = selectStocksForSnapshot(effectiveLimit);
        final List<Stock> stocks = selectedStocks.stocks();
        final Set<Long> portfolioStockIds =
                new HashSet<>(stockPriceSnapshotMapper.findActivePortfolioStockIds());
        final LocalDate snapshotDate = LocalDate.now(SNAPSHOT_ZONE);
        final long startedAtNanos = System.nanoTime();

        int savedCount = 0;
        int failedCount = 0;

        log.info(
                "가격 스냅샷 배치를 시작합니다. snapshotDate={}, totalRequested={}, portfolioStocks={}, generalStocks={}, generalLimit={}, requestMode=QUOTE_ALL_METRIC_PORTFOLIO",
                snapshotDate,
                stocks.size(),
                selectedStocks.portfolioCount(),
                selectedStocks.generalCount(),
                effectiveLimit
        );
        for (int index = 0; index < stocks.size(); index++) {
            final Stock stock = stocks.get(index);
            try {
                final String symbol = stock.getFinnhubSymbol() == null || stock.getFinnhubSymbol().isBlank()
                        ? stock.getTicker()
                        : stock.getFinnhubSymbol();
                final StockPriceSnapshotRecord previousSnapshot =
                        stockPriceSnapshotMapper.findLatestSnapshotByStockId(stock.getId());
                final boolean fetchMetrics = portfolioStockIds.contains(stock.getId())
                        || needsFundamentalRefresh(previousSnapshot, snapshotDate);
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
                final BigDecimal grossMarginTtm = firstNonNull(
                        decimalOrNull(snapshotData.grossMarginTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getGrossMarginTtm()
                );
                final BigDecimal netMarginTtm = firstNonNull(
                        decimalOrNull(snapshotData.netMarginTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getNetMarginTtm()
                );
                final BigDecimal operatingMarginTtm = firstNonNull(
                        decimalOrNull(snapshotData.operatingMarginTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getOperatingMarginTtm()
                );
                final BigDecimal roeTtm = firstNonNull(
                        decimalOrNull(snapshotData.roeTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getRoeTtm()
                );
                final BigDecimal roaTtm = firstNonNull(
                        decimalOrNull(snapshotData.roaTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getRoaTtm()
                );
                final BigDecimal roicTtm = firstNonNull(
                        decimalOrNull(snapshotData.roicTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getRoicTtm()
                );
                final BigDecimal debtToEquityTtm = firstNonNull(
                        decimalOrNull(snapshotData.debtToEquityTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getDebtToEquityTtm()
                );
                final BigDecimal currentRatioTtm = firstNonNull(
                        decimalOrNull(snapshotData.currentRatioTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getCurrentRatioTtm()
                );
                final BigDecimal quickRatioTtm = firstNonNull(
                        decimalOrNull(snapshotData.quickRatioTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getQuickRatioTtm()
                );
                final BigDecimal assetTurnoverTtm = firstNonNull(
                        decimalOrNull(snapshotData.assetTurnoverTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getAssetTurnoverTtm()
                );
                final BigDecimal freeCashFlowYieldTtm = firstNonNull(
                        decimalOrNull(snapshotData.freeCashFlowYieldTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getFreeCashFlowYieldTtm()
                );
                final BigDecimal operatingCashFlowRatioTtm = firstNonNull(
                        decimalOrNull(snapshotData.operatingCashFlowRatioTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getOperatingCashFlowRatioTtm()
                );
                final BigDecimal incomeQualityTtm = firstNonNull(
                        decimalOrNull(snapshotData.incomeQualityTtm()),
                        previousSnapshot == null ? null : previousSnapshot.getIncomeQualityTtm()
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
                        grossMarginTtm,
                        netMarginTtm,
                        operatingMarginTtm,
                        roeTtm,
                        roaTtm,
                        roicTtm,
                        debtToEquityTtm,
                        currentRatioTtm,
                        quickRatioTtm,
                        assetTurnoverTtm,
                        freeCashFlowYieldTtm,
                        operatingCashFlowRatioTtm,
                        incomeQualityTtm,
                        resolveSnapshotSource(fetchMetrics, snapshotData, fmpApiKey)
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

    public PriceHistoryBackfillResult backfillHistoricalSnapshots(Integer limit, Integer lookbackDays) {
        final String fmpApiKey = System.getenv("FMP_API_KEY");

        final int effectiveLimit = limit == null || limit <= 0
                ? properties.getDefaultLimit()
                : limit;
        final int effectiveLookbackDays = lookbackDays == null || lookbackDays <= 0
                ? properties.getHistoryLookbackDays()
                : lookbackDays;
        final SelectedStocks selectedStocks = selectStocksForSnapshot(effectiveLimit);
        final List<Stock> stocks = selectedStocks.stocks();
        final LocalDate today = LocalDate.now(SNAPSHOT_ZONE);
        final LocalDate fromDate = today.minusDays(effectiveLookbackDays);
        final LocalDate toDate = today.minusDays(1);

        int historyRowCount = 0;
        int refreshedCurrentSnapshotCount = 0;
        int failedStockCount = 0;
        final List<String> failedTickers = new ArrayList<>();

        log.info(
                "과거 가격 백필을 시작합니다. fromDate={}, toDate={}, totalRequested={}, portfolioStocks={}, generalStocks={}, generalLimit={}",
                fromDate,
                toDate,
                stocks.size(),
                selectedStocks.portfolioCount(),
                selectedStocks.generalCount(),
                effectiveLimit
        );

        for (Stock stock : stocks) {
            try {
                historyRowCount += backfillHistoricalSnapshotsForStock(stock, fromDate, toDate, fmpApiKey);
                if (syncLatestSnapshotForStock(stock.getId())) {
                    refreshedCurrentSnapshotCount++;
                }
            } catch (Exception exception) {
                failedStockCount++;
                log.warn(
                        "과거 가격 백필에 실패했습니다. stockId={}, ticker={}",
                        stock.getId(),
                        stock.getTicker(),
                        exception
                );
            } finally {
                sleep(Math.max(200, properties.getDelayMillis() / 3));
            }
        }

        log.info(
                "과거 가격 백필이 완료되었습니다. stocks={}, historyRows={}, refreshedCurrent={}, failedStocks={}",
                stocks.size(),
                historyRowCount,
                refreshedCurrentSnapshotCount,
                failedStockCount
        );
        return new PriceHistoryBackfillResult(
                fromDate,
                toDate,
                stocks.size(),
                historyRowCount,
                refreshedCurrentSnapshotCount,
                failedStockCount,
                List.of()
        );
    }

    public PriceHistoryBackfillResult backfillNullThirtyDaySnapshots(Integer limit, Integer lookbackDays) {
        final String fmpApiKey = System.getenv("FMP_API_KEY");

        final int effectiveLimit = limit == null || limit <= 0
                ? properties.getDefaultLimit()
                : limit;
        final int effectiveLookbackDays = lookbackDays == null || lookbackDays <= 0
                ? Math.max(properties.getHistoryLookbackDays(), EXTENDED_RETRY_LOOKBACK_DAYS)
                : lookbackDays;
        final SelectedStocks selectedStocks = selectStocksForThirtyDayRecovery(effectiveLimit);
        final List<Stock> stocks = selectedStocks.stocks();
        final LocalDate today = LocalDate.now(SNAPSHOT_ZONE);
        final LocalDate fromDate = today.minusDays(effectiveLookbackDays);
        final LocalDate toDate = today.minusDays(1);

        int historyRowCount = 0;
        int refreshedCurrentSnapshotCount = 0;
        int failedStockCount = 0;
        final List<String> failedTickers = new ArrayList<>();

        log.info(
                "30일 수익률 null 전용 가격 백필을 시작합니다. fromDate={}, toDate={}, totalRequested={}, portfolioStocks={}, generalStocks={}, generalLimit={}",
                fromDate,
                toDate,
                stocks.size(),
                selectedStocks.portfolioCount(),
                selectedStocks.generalCount(),
                effectiveLimit
        );

        for (Stock stock : stocks) {
            try {
                historyRowCount += backfillHistoricalSnapshotsForStock(stock, fromDate, toDate, fmpApiKey);
                if (syncLatestSnapshotForStock(stock.getId())) {
                    refreshedCurrentSnapshotCount++;
                }
            } catch (Exception exception) {
                failedStockCount++;
                failedTickers.add(stock.getTicker());
                log.warn(
                        "30일 수익률 null 전용 가격 백필에 실패했습니다. stockId={}, ticker={}",
                        stock.getId(),
                        stock.getTicker(),
                        exception
                );
            } finally {
                sleep(Math.max(200, properties.getDelayMillis() / 3));
            }
        }

        log.info(
                "30일 수익률 null 전용 가격 백필이 완료되었습니다. stocks={}, historyRows={}, refreshedCurrent={}, failedStocks={}, failedTickers={}",
                stocks.size(),
                historyRowCount,
                refreshedCurrentSnapshotCount,
                failedStockCount,
                failedTickers
        );
        return new PriceHistoryBackfillResult(
                fromDate,
                toDate,
                stocks.size(),
                historyRowCount,
                refreshedCurrentSnapshotCount,
                failedStockCount,
                List.copyOf(failedTickers)
        );
    }

    public boolean syncLatestSnapshotForStock(Long stockId) {
        if (stockId == null) {
            return false;
        }

        final String apiKey = System.getenv("FINNHUB_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("FINNHUB_API_KEY 환경변수가 필요합니다.");
        }

        final Stock stock = stockPriceSnapshotMapper.findStockForSnapshotById(stockId);
        if (stock == null) {
            return false;
        }

        final String fmpApiKey = System.getenv("FMP_API_KEY");
        final LocalDate snapshotDate = LocalDate.now(SNAPSHOT_ZONE);
        try {
            saveSnapshotForStock(
                    stock,
                    snapshotDate,
                    apiKey,
                    fmpApiKey,
                    true
            );
            log.info("단일 종목 가격 스냅샷을 갱신했습니다. stockId={}, ticker={}", stockId, stock.getTicker());
            return true;
        } catch (Exception exception) {
            log.warn("단일 종목 가격 스냅샷 갱신에 실패했습니다. stockId={}, ticker={}", stockId, stock.getTicker(), exception);
            return false;
        }
    }

    public boolean ensureRecommendationSnapshot(Long stockId) {
        if (stockId == null) {
            return false;
        }

        final LocalDate today = LocalDate.now(SNAPSHOT_ZONE);
        final Stock stock = stockPriceSnapshotMapper.findStockForSnapshotById(stockId);
        if (stock == null) {
            return false;
        }
        refreshStockIpoDateIfMissing(stock, System.getenv("FMP_API_KEY"));
        if (isEtfStock(stock)) {
            return false;
        }
        StockPriceSnapshotRecord latestSnapshot =
                stockPriceSnapshotMapper.findLatestSnapshotByStockId(stockId);
        boolean updated = false;
        final boolean needsImmediateLatestSync = latestSnapshot == null
                || latestSnapshot.getSnapshotDate() == null
                || latestSnapshot.getSnapshotDate().isBefore(today)
                || latestSnapshot.getCurrentPrice() == null
                || latestSnapshot.getCurrentPrice().doubleValue() <= 0
                || (hasInsufficientCoreFundamentals(latestSnapshot)
                && !isRecentlyListedForFundamentals(stock, today));

        if (needsImmediateLatestSync) {
            updated = syncLatestSnapshotForStock(stockId) || updated;
            latestSnapshot = stockPriceSnapshotMapper.findLatestSnapshotByStockId(stockId);
        }

        if (needsPriceHistoryBackfill(stock, latestSnapshot, today)) {
            final int savedHistoryRows = backfillHistoricalSnapshotsForStockIds(
                    List.of(stockId),
                    properties.getHistoryLookbackDays()
            );
            updated = updated || savedHistoryRows > 0;
            latestSnapshot = stockPriceSnapshotMapper.findLatestSnapshotByStockId(stockId);
        }

        if (needsImmediateBackfillRetry(stock, latestSnapshot, today)) {
            final int retriedRows = backfillHistoricalSnapshotsForStockIds(
                    List.of(stockId),
                    Math.max(properties.getHistoryLookbackDays(), EXTENDED_RETRY_LOOKBACK_DAYS)
            );
            updated = updated || retriedRows > 0;
            latestSnapshot = stockPriceSnapshotMapper.findLatestSnapshotByStockId(stockId);
        }

        if (!needsFundamentalRefresh(latestSnapshot, today)) {
            return updated;
        }
        if (latestSnapshot != null
                && latestSnapshot.getSnapshotDate() != null
                && !latestSnapshot.getSnapshotDate().isBefore(today)
                && hasInsufficientCoreFundamentals(latestSnapshot)
                && isRecentlyListedForFundamentals(stock, today)) {
            return updated;
        }
        return syncLatestSnapshotForStock(stockId) || updated;
    }

    public int backfillHistoricalSnapshotsForStockIds(List<Long> stockIds, Integer lookbackDays) {
        if (stockIds == null || stockIds.isEmpty()) {
            return 0;
        }
        final String fmpApiKey = System.getenv("FMP_API_KEY");

        final int effectiveLookbackDays = lookbackDays == null || lookbackDays <= 0
                ? properties.getHistoryLookbackDays()
                : lookbackDays;
        final LocalDate today = LocalDate.now(SNAPSHOT_ZONE);
        final LocalDate fromDate = today.minusDays(effectiveLookbackDays);
        final LocalDate toDate = today.minusDays(1);

        int savedRows = 0;
        for (Long stockId : stockIds) {
            if (stockId == null) {
                continue;
            }
            final Stock stock = stockPriceSnapshotMapper.findStockForSnapshotById(stockId);
            if (stock == null) {
                continue;
            }
            try {
                savedRows += backfillHistoricalSnapshotsForStock(stock, fromDate, toDate, fmpApiKey);
                syncLatestSnapshotForStock(stockId);
            } catch (Exception exception) {
                throw new IllegalStateException(
                        "과거 가격 백필에 실패했습니다. stockId=" + stockId + ", ticker=" + stock.getTicker(),
                        exception
                );
            } finally {
                sleep(Math.max(600, properties.getDelayMillis() / 2));
            }
        }
        return savedRows;
    }

    private void saveSnapshotForStock(
            Stock stock,
            LocalDate snapshotDate,
            String apiKey,
            String fmpApiKey,
            boolean fetchMetrics
    ) throws Exception {
        final String symbol = stock.getFinnhubSymbol() == null || stock.getFinnhubSymbol().isBlank()
                ? stock.getTicker()
                : stock.getFinnhubSymbol();
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
        final BigDecimal grossMarginTtm = firstNonNull(
                decimalOrNull(snapshotData.grossMarginTtm()),
                previousSnapshot == null ? null : previousSnapshot.getGrossMarginTtm()
        );
        final BigDecimal netMarginTtm = firstNonNull(
                decimalOrNull(snapshotData.netMarginTtm()),
                previousSnapshot == null ? null : previousSnapshot.getNetMarginTtm()
        );
        final BigDecimal operatingMarginTtm = firstNonNull(
                decimalOrNull(snapshotData.operatingMarginTtm()),
                previousSnapshot == null ? null : previousSnapshot.getOperatingMarginTtm()
        );
        final BigDecimal roeTtm = firstNonNull(
                decimalOrNull(snapshotData.roeTtm()),
                previousSnapshot == null ? null : previousSnapshot.getRoeTtm()
        );
        final BigDecimal roaTtm = firstNonNull(
                decimalOrNull(snapshotData.roaTtm()),
                previousSnapshot == null ? null : previousSnapshot.getRoaTtm()
        );
        final BigDecimal roicTtm = firstNonNull(
                decimalOrNull(snapshotData.roicTtm()),
                previousSnapshot == null ? null : previousSnapshot.getRoicTtm()
        );
        final BigDecimal debtToEquityTtm = firstNonNull(
                decimalOrNull(snapshotData.debtToEquityTtm()),
                previousSnapshot == null ? null : previousSnapshot.getDebtToEquityTtm()
        );
        final BigDecimal currentRatioTtm = firstNonNull(
                decimalOrNull(snapshotData.currentRatioTtm()),
                previousSnapshot == null ? null : previousSnapshot.getCurrentRatioTtm()
        );
        final BigDecimal quickRatioTtm = firstNonNull(
                decimalOrNull(snapshotData.quickRatioTtm()),
                previousSnapshot == null ? null : previousSnapshot.getQuickRatioTtm()
        );
        final BigDecimal assetTurnoverTtm = firstNonNull(
                decimalOrNull(snapshotData.assetTurnoverTtm()),
                previousSnapshot == null ? null : previousSnapshot.getAssetTurnoverTtm()
        );
        final BigDecimal freeCashFlowYieldTtm = firstNonNull(
                decimalOrNull(snapshotData.freeCashFlowYieldTtm()),
                previousSnapshot == null ? null : previousSnapshot.getFreeCashFlowYieldTtm()
        );
        final BigDecimal operatingCashFlowRatioTtm = firstNonNull(
                decimalOrNull(snapshotData.operatingCashFlowRatioTtm()),
                previousSnapshot == null ? null : previousSnapshot.getOperatingCashFlowRatioTtm()
        );
        final BigDecimal incomeQualityTtm = firstNonNull(
                decimalOrNull(snapshotData.incomeQualityTtm()),
                previousSnapshot == null ? null : previousSnapshot.getIncomeQualityTtm()
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
                grossMarginTtm,
                netMarginTtm,
                operatingMarginTtm,
                roeTtm,
                roaTtm,
                roicTtm,
                debtToEquityTtm,
                currentRatioTtm,
                quickRatioTtm,
                assetTurnoverTtm,
                freeCashFlowYieldTtm,
                operatingCashFlowRatioTtm,
                incomeQualityTtm,
                resolveSnapshotSource(fetchMetrics, snapshotData, fmpApiKey)
        );
    }

    int backfillHistoricalSnapshotsForStock(
            Stock stock,
            LocalDate fromDate,
            LocalDate toDate,
            String fmpApiKey
    ) {
        if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
            return 0;
        }
        try {
            final String symbol = stock.getFinnhubSymbol() == null || stock.getFinnhubSymbol().isBlank()
                    ? stock.getTicker()
                    : stock.getFinnhubSymbol();
            final List<HistoricalPricePoint> pricePoints = fetchHistoricalPricePoints(
                    symbol,
                    fromDate,
                    toDate,
                    fmpApiKey
            );
            if (pricePoints.isEmpty()) {
                return 0;
            }

            pricePoints.sort(Comparator.comparing(HistoricalPricePoint::date));
            final Map<LocalDate, BigDecimal> closeByDate = new HashMap<>();
            int savedRows = 0;
            for (int index = 0; index < pricePoints.size(); index++) {
                final HistoricalPricePoint point = pricePoints.get(index);
                final BigDecimal previousPrice = index == 0 ? null : pricePoints.get(index - 1).closePrice();
                final BigDecimal sevenDayPrice = findReferencePriceFromSeries(
                        closeByDate,
                        point.date().minusDays(7),
                        point.date().minusDays(14)
                );
                final BigDecimal thirtyDayPrice = findReferencePriceFromSeries(
                        closeByDate,
                        point.date().minusDays(30),
                        point.date().minusDays(40)
                );
                stockPriceSnapshotMapper.upsertHistoricalPriceSnapshot(
                        stock.getId(),
                        point.date(),
                        point.closePrice(),
                        priceReturnCalculator.calculate(point.closePrice(), previousPrice),
                        priceReturnCalculator.calculate(point.closePrice(), sevenDayPrice),
                        priceReturnCalculator.calculate(point.closePrice(), thirtyDayPrice),
                        point.source()
                );
                closeByDate.put(point.date(), point.closePrice());
                savedRows++;
            }
            return savedRows;
        } catch (Exception exception) {
            throw new IllegalStateException(
                    "과거 가격 백필 내부 처리에 실패했습니다. stockId=" + stock.getId() + ", ticker=" + stock.getTicker(),
                    exception
            );
        }
    }

    private String resolveSnapshotSource(
            boolean fetchMetrics,
            SnapshotData snapshotData,
            String fmpApiKey
    ) {
        if (!fetchMetrics) {
            return SOURCE;
        }
        if (!hasText(fmpApiKey)) {
            return SOURCE;
        }
        return snapshotData.hasFmpFundamentals() ? FMP_MODEL_SOURCE : FMP_EMPTY_SOURCE;
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
        final JsonNode metricNode = metrics == null ? null : metrics.path("metric");
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
        final JsonNode incomeStatements = fetchMetrics && hasText(fmpApiKey)
                ? getJsonOrNull(
                        "https://financialmodelingprep.com/stable/income-statement?symbol="
                                + encode(symbol)
                                + "&limit=2&apikey="
                                + encode(fmpApiKey),
                        symbol
                )
                : null;
        final JsonNode balanceSheets = fetchMetrics && hasText(fmpApiKey)
                ? getJsonOrNull(
                        "https://financialmodelingprep.com/stable/balance-sheet-statement?symbol="
                                + encode(symbol)
                                + "&limit=1&apikey="
                                + encode(fmpApiKey),
                        symbol
                )
                : null;
        final JsonNode cashFlows = fetchMetrics && hasText(fmpApiKey)
                ? getJsonOrNull(
                        "https://financialmodelingprep.com/stable/cash-flow-statement?symbol="
                                + encode(symbol)
                                + "&limit=1&apikey="
                                + encode(fmpApiKey),
                        symbol
                )
                : null;
        final JsonNode keyMetricNode = firstValueNode(keyMetrics);
        final JsonNode ratioNode = firstValueNode(ratios);
        final JsonNode growthNode = firstValueNode(incomeGrowth);
        final JsonNode incomeStatementNode = firstValueNode(incomeStatements);
        final JsonNode previousIncomeStatementNode = nthValueNode(incomeStatements, 1);
        final JsonNode balanceSheetNode = firstValueNode(balanceSheets);
        final JsonNode cashFlowNode = firstValueNode(cashFlows);

        final Double fallbackRevenueGrowth = deriveRevenueGrowthFromStatements(
                incomeStatementNode,
                previousIncomeStatementNode
        );
        final Double fallbackGrossMargin = deriveMarginRatio(incomeStatementNode, "grossProfit", "revenue");
        final Double fallbackNetMargin = deriveMarginRatio(incomeStatementNode, "netIncome", "revenue");
        final Double fallbackOperatingMargin = deriveMarginRatio(incomeStatementNode, "operatingIncome", "revenue");
        final Double fallbackRoe = deriveReturnRatio(incomeStatementNode, "netIncome", balanceSheetNode, "totalStockholdersEquity");
        final Double fallbackRoa = deriveReturnRatio(incomeStatementNode, "netIncome", balanceSheetNode, "totalAssets");
        final Double fallbackDebtToEquity = deriveRatio(balanceSheetNode, "totalDebt", balanceSheetNode, "totalStockholdersEquity");
        final Double fallbackCurrentRatio = deriveRatio(balanceSheetNode, "totalCurrentAssets", balanceSheetNode, "totalCurrentLiabilities");
        final Double fallbackQuickRatio = deriveQuickRatio(balanceSheetNode);
        final Double fallbackAssetTurnover = deriveRatio(incomeStatementNode, "revenue", balanceSheetNode, "totalAssets");
        final Double fallbackFcfYield = deriveFreeCashFlowYieldFromStatements(
                cashFlowNode,
                firstNonNull(
                        readNullableDouble(keyMetricNode, "marketCap"),
                        readNullableDouble(metricNode, "marketCapitalization")
                )
        );
        final Double fallbackOperatingCashFlowRatio = deriveRatio(
                cashFlowNode,
                "operatingCashFlow",
                balanceSheetNode,
                "totalCurrentLiabilities"
        );
        final Double fallbackIncomeQuality = deriveIncomeQualityFromStatements(cashFlowNode, incomeStatementNode);
        final Double fallbackEps = deriveEpsFromStatements(incomeStatementNode);

        return new SnapshotData(
                readPositiveDouble(quote, "c"),
                firstNonNull(
                        readNullableDouble(keyMetricNode, "marketCap"),
                        readNullableDouble(metricNode, "marketCapitalization")
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "priceToEarningsRatioTTM"),
                        firstNonNull(
                                readNullableDouble(metricNode, "peTTM"),
                                derivePriceToEarningsFromStatements(readPositiveDouble(quote, "c"), fallbackEps)
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "netIncomePerShareTTM"),
                        firstNonNull(
                                readNullableDouble(metricNode, "epsTTM"),
                                fallbackEps
                        )
                ),
                firstNonNull(
                        readNullableDouble(growthNode, "growthRevenue"),
                        firstNonNull(
                                readNormalizedPercentage(metricNode, "revenueGrowthTTMYoy"),
                                fallbackRevenueGrowth
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "grossProfitMarginTTM"),
                        firstNonNull(
                                readNormalizedPercentage(metricNode, "grossMarginTTM"),
                                fallbackGrossMargin
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "netProfitMarginTTM"),
                        firstNonNull(
                                readNormalizedPercentage(metricNode, "netProfitMarginTTM"),
                                fallbackNetMargin
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "operatingProfitMarginTTM"),
                        firstNonNull(
                                readNormalizedPercentage(metricNode, "operatingMarginTTM"),
                                fallbackOperatingMargin
                        )
                ),
                firstNonNull(
                        readNullableDouble(keyMetricNode, "returnOnEquityTTM"),
                        firstNonNull(
                                readNormalizedPercentage(metricNode, "roeTTM"),
                                fallbackRoe
                        )
                ),
                firstNonNull(
                        readNullableDouble(keyMetricNode, "returnOnAssetsTTM"),
                        firstNonNull(
                                readNormalizedPercentage(metricNode, "roaTTM"),
                                fallbackRoa
                        )
                ),
                firstNonNull(
                        readNullableDouble(keyMetricNode, "returnOnInvestedCapitalTTM"),
                        readNormalizedPercentage(metricNode, "roiTTM")
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "debtToEquityRatioTTM"),
                        firstNonNull(
                                readNullableDouble(metricNode, "totalDebt/totalEquityAnnual"),
                                fallbackDebtToEquity
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "currentRatioTTM"),
                        firstNonNull(
                                readNullableDouble(metricNode, "currentRatioAnnual"),
                                fallbackCurrentRatio
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "quickRatioTTM"),
                        firstNonNull(
                                readNullableDouble(metricNode, "quickRatioAnnual"),
                                fallbackQuickRatio
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "assetTurnoverTTM"),
                        firstNonNull(
                                readNullableDouble(metricNode, "assetTurnoverTTM"),
                                fallbackAssetTurnover
                        )
                ),
                firstNonNull(
                        readNullableDouble(keyMetricNode, "freeCashFlowYieldTTM"),
                        firstNonNull(
                                deriveFreeCashFlowYield(metricNode),
                                fallbackFcfYield
                        )
                ),
                firstNonNull(
                        readNullableDouble(ratioNode, "operatingCashFlowRatioTTM"),
                        fallbackOperatingCashFlowRatio
                ),
                firstNonNull(
                        readNullableDouble(keyMetricNode, "incomeQualityTTM"),
                        firstNonNull(
                                deriveIncomeQuality(metricNode),
                                fallbackIncomeQuality
                        )
                )
        );
    }

    private List<HistoricalPricePoint> fetchHistoricalPricePoints(
            String symbol,
            LocalDate fromDate,
            LocalDate toDate,
            String fmpApiKey
    ) throws Exception {
        if (hasText(fmpApiKey)) {
            try {
                final List<HistoricalPricePoint> fmpPoints = fetchFmpHistoricalPricePoints(
                        symbol,
                        fromDate,
                        toDate,
                        fmpApiKey
                );
                if (!fmpPoints.isEmpty()) {
                    return fmpPoints;
                }
            } catch (Exception exception) {
                log.info(
                        "FMP 과거 가격은 사용할 수 없어 Yahoo fallback으로 전환합니다. symbol={}, reason={}",
                        symbol,
                        exception.getMessage()
                );
            }
        }
        return fetchYahooHistoricalPricePoints(symbol, fromDate, toDate);
    }

    private List<HistoricalPricePoint> fetchFmpHistoricalPricePoints(
            String symbol,
            LocalDate fromDate,
            LocalDate toDate,
            String fmpApiKey
    ) throws Exception {
        final JsonNode response = getExternalJson(
                "https://financialmodelingprep.com/stable/historical-price-eod/light?symbol="
                        + encode(symbol)
                        + "&from="
                        + fromDate
                        + "&to="
                        + toDate
                        + "&apikey="
                        + encode(fmpApiKey),
                "FMP historical price"
        );
        final JsonNode values = response.path("value");
        if (!values.isArray() || values.isEmpty()) {
            return List.of();
        }
        final List<HistoricalPricePoint> result = new ArrayList<>();
        for (JsonNode item : values) {
            if (item == null || item.isMissingNode() || item.isNull()) {
                continue;
            }
            final String dateText = item.path("date").asText(null);
            final Double price = readNullableDouble(item, "price");
            if (dateText == null || price == null || price <= 0) {
                continue;
            }
            result.add(new HistoricalPricePoint(
                    LocalDate.parse(dateText),
                    BigDecimal.valueOf(price).setScale(4, RoundingMode.HALF_UP),
                    "FMP_HISTORY"
            ));
        }
        return result;
    }

    private List<HistoricalPricePoint> fetchYahooHistoricalPricePoints(
            String symbol,
            LocalDate fromDate,
            LocalDate toDate
    ) throws Exception {
        final long period1 = fromDate.atStartOfDay(ZoneId.of("UTC")).toEpochSecond();
        final long period2 = toDate.plusDays(1).atStartOfDay(ZoneId.of("UTC")).toEpochSecond() - 1;
        final JsonNode response = getExternalJson(
                "https://query1.finance.yahoo.com/v8/finance/chart/"
                        + encode(symbol)
                        + "?period1="
                        + period1
                        + "&period2="
                        + period2
                        + "&interval=1d&includePrePost=false&events=div%2Csplits",
                "Yahoo historical price"
        );
        final JsonNode resultNode = response.path("chart").path("result");
        if (!resultNode.isArray() || resultNode.isEmpty()) {
            return List.of();
        }
        final JsonNode first = resultNode.get(0);
        final JsonNode timestamps = first.path("timestamp");
        final JsonNode closeValues = first.path("indicators").path("quote").get(0).path("close");
        if (!timestamps.isArray() || !closeValues.isArray()) {
            return List.of();
        }

        final List<HistoricalPricePoint> result = new ArrayList<>();
        final int size = Math.min(timestamps.size(), closeValues.size());
        for (int index = 0; index < size; index++) {
            final JsonNode tsNode = timestamps.get(index);
            final JsonNode closeNode = closeValues.get(index);
            if (tsNode == null || closeNode == null || closeNode.isNull()) {
                continue;
            }
            final LocalDate date = java.time.Instant.ofEpochSecond(tsNode.asLong())
                    .atZone(ZoneId.of("America/New_York"))
                    .toLocalDate();
            final double closePrice = closeNode.asDouble(Double.NaN);
            if (Double.isNaN(closePrice) || closePrice <= 0) {
                continue;
            }
            result.add(new HistoricalPricePoint(
                    date,
                    BigDecimal.valueOf(closePrice).setScale(4, RoundingMode.HALF_UP),
                    "YAHOO_CHART_HISTORY"
            ));
        }
        return result;
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

    private JsonNode nthValueNode(JsonNode root, int index) {
        if (root == null || root.isMissingNode() || root.isNull() || index < 0) {
            return null;
        }
        if (root.isArray()) {
            return root.size() <= index ? null : root.get(index);
        }
        final JsonNode value = root.path("value");
        if (!value.isArray() || value.size() <= index) {
            return null;
        }
        return value.get(index);
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

    private JsonNode getExternalJson(String uri, String sourceName) throws Exception {
        for (int attempt = 1; attempt <= 3; attempt++) {
            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .timeout(Duration.ofSeconds(20))
                    .header("Accept", "application/json,text/plain,*/*")
                    .header(
                            "User-Agent",
                            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0 Safari/537.36"
                    )
                    .GET()
                    .build();

            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );
            if (response.statusCode() == 200 && !response.body().isBlank()) {
                return objectMapper.readTree(response.body());
            }
            if (response.statusCode() == 429 && attempt < 3) {
                final long backoffMillis = attempt * 1500L;
                log.info(
                        "{} 요청이 제한되어 재시도합니다. attempt={}/3, backoffMillis={}",
                        sourceName,
                        attempt,
                        backoffMillis
                );
                sleep((int) backoffMillis);
                continue;
            }
            throw new IllegalStateException(sourceName + " 응답이 비정상입니다. status=" + response.statusCode());
        }
        throw new IllegalStateException(sourceName + " 응답이 비정상입니다.");
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

    private String readNullableText(JsonNode node, String fieldName) {
        if (node == null || node.isMissingNode() || node.path(fieldName).isMissingNode() || node.path(fieldName).isNull()) {
            return null;
        }
        final String value = node.path(fieldName).asText(null);
        return value == null || value.isBlank() ? null : value.trim();
    }

    private Double readNormalizedPercentage(JsonNode node, String fieldName) {
        final Double value = readNullableDouble(node, fieldName);
        if (value == null) {
            return null;
        }
        return normalizePercent(value);
    }

    private Double normalizePercent(Double value) {
        if (value == null) {
            return null;
        }
        return Math.abs(value) > 1.0 ? value / 100.0 : value;
    }

    private Double deriveFreeCashFlowYield(JsonNode metricNode) {
        final Double evToFcf = readNullableDouble(metricNode, "currentEv/freeCashFlowTTM");
        if (evToFcf == null || evToFcf <= 0) {
            return null;
        }
        return 1 / evToFcf;
    }

    private Double deriveIncomeQuality(JsonNode metricNode) {
        final Double cashFlowPerShare = readNullableDouble(metricNode, "cashFlowPerShareTTM");
        final Double epsTtm = readNullableDouble(metricNode, "epsTTM");
        if (cashFlowPerShare == null || epsTtm == null || epsTtm == 0) {
            return null;
        }
        return cashFlowPerShare / epsTtm;
    }

    private Double deriveRevenueGrowthFromStatements(JsonNode latestIncomeStatement, JsonNode previousIncomeStatement) {
        final Double latestRevenue = readNullableDouble(latestIncomeStatement, "revenue");
        final Double previousRevenue = readNullableDouble(previousIncomeStatement, "revenue");
        if (latestRevenue == null || previousRevenue == null || previousRevenue == 0) {
            return null;
        }
        return (latestRevenue - previousRevenue) / previousRevenue;
    }

    private Double deriveMarginRatio(JsonNode numeratorNode, String numeratorField, String revenueField) {
        final Double numerator = readNullableDouble(numeratorNode, numeratorField);
        final Double revenue = readNullableDouble(numeratorNode, revenueField);
        return safeDivide(numerator, revenue);
    }

    private Double deriveReturnRatio(JsonNode numeratorNode, String numeratorField, JsonNode denominatorNode, String denominatorField) {
        final Double numerator = readNullableDouble(numeratorNode, numeratorField);
        final Double denominator = readNullableDouble(denominatorNode, denominatorField);
        return safeDivide(numerator, denominator);
    }

    private Double deriveRatio(JsonNode numeratorNode, String numeratorField, JsonNode denominatorNode, String denominatorField) {
        final Double numerator = readNullableDouble(numeratorNode, numeratorField);
        final Double denominator = readNullableDouble(denominatorNode, denominatorField);
        return safeDivide(numerator, denominator);
    }

    private Double deriveQuickRatio(JsonNode balanceSheetNode) {
        final Double cash = firstNonNull(
                readNullableDouble(balanceSheetNode, "cashAndCashEquivalents"),
                readNullableDouble(balanceSheetNode, "cashAndShortTermInvestments")
        );
        final Double receivables = readNullableDouble(balanceSheetNode, "netReceivables");
        final Double currentLiabilities = readNullableDouble(balanceSheetNode, "totalCurrentLiabilities");
        if (currentLiabilities == null || currentLiabilities == 0) {
            return null;
        }
        double numerator = 0;
        boolean hasComponent = false;
        if (cash != null) {
            numerator += cash;
            hasComponent = true;
        }
        if (receivables != null) {
            numerator += receivables;
            hasComponent = true;
        }
        if (!hasComponent) {
            return null;
        }
        return numerator / currentLiabilities;
    }

    private Double deriveFreeCashFlowYieldFromStatements(JsonNode cashFlowNode, Double marketCap) {
        final Double freeCashFlow = readNullableDouble(cashFlowNode, "freeCashFlow");
        if (freeCashFlow == null || marketCap == null || marketCap == 0) {
            return null;
        }
        return freeCashFlow / marketCap;
    }

    private Double deriveIncomeQualityFromStatements(JsonNode cashFlowNode, JsonNode incomeStatementNode) {
        final Double operatingCashFlow = readNullableDouble(cashFlowNode, "operatingCashFlow");
        final Double netIncome = readNullableDouble(incomeStatementNode, "netIncome");
        return safeDivide(operatingCashFlow, netIncome);
    }

    private Double deriveEpsFromStatements(JsonNode incomeStatementNode) {
        return firstNonNull(
                readNullableDouble(incomeStatementNode, "epsdiluted"),
                readNullableDouble(incomeStatementNode, "eps")
        );
    }

    private Double derivePriceToEarningsFromStatements(Double currentPrice, Double eps) {
        if (currentPrice == null || eps == null || eps == 0) {
            return null;
        }
        return currentPrice / eps;
    }

    private Double safeDivide(Double numerator, Double denominator) {
        if (numerator == null || denominator == null || denominator == 0) {
            return null;
        }
        return numerator / denominator;
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

    private boolean needsFundamentalRefresh(StockPriceSnapshotRecord snapshot, LocalDate today) {
        if (snapshot == null) {
            return true;
        }
        if (snapshot.getCurrentPrice() == null || snapshot.getCurrentPrice().doubleValue() <= 0) {
            return true;
        }
        if (!hasInsufficientCoreFundamentals(snapshot)) {
            return false;
        }
        if (snapshot.getSnapshotDate() == null || snapshot.getSnapshotDate().isBefore(today)) {
            return true;
        }
        return !FMP_EMPTY_SOURCE.equals(snapshot.getSource());
    }

    private boolean needsPriceHistoryBackfill(Stock stock, StockPriceSnapshotRecord snapshot, LocalDate today) {
        if (snapshot == null) {
            return true;
        }
        if (snapshot.getCurrentPrice() == null || snapshot.getCurrentPrice().doubleValue() <= 0) {
            return true;
        }
        if (isEtfStock(stock)) {
            return false;
        }
        if (snapshot.getChangeRate7d() != null
                && snapshot.getChangeRate30d() == null
                && isRecentlyListedForPriceHistory(stock, today)) {
            return false;
        }
        return snapshot.getChangeRate7d() == null || snapshot.getChangeRate30d() == null;
    }

    private boolean needsImmediateBackfillRetry(Stock stock, StockPriceSnapshotRecord snapshot, LocalDate today) {
        if (snapshot == null || isEtfStock(stock)) {
            return false;
        }
        if (snapshot.getChangeRate30d() != null) {
            return false;
        }
        if (isRecentlyListedForPriceHistory(stock, today)) {
            return false;
        }
        return snapshot.getChangeRate7d() != null
                || snapshot.getSnapshotDate() == null
                || !snapshot.getSnapshotDate().isBefore(today);
    }

    private boolean hasInsufficientCoreFundamentals(StockPriceSnapshotRecord snapshot) {
        int presentCount = 0;
        if (snapshot.getEpsTtm() != null) {
            presentCount++;
        }
        if (snapshot.getRevenueGrowthYoy() != null) {
            presentCount++;
        }
        if (snapshot.getOperatingMarginTtm() != null) {
            presentCount++;
        }
        if (snapshot.getRoeTtm() != null) {
            presentCount++;
        }
        if (snapshot.getFreeCashFlowYieldTtm() != null) {
            presentCount++;
        }
        if (snapshot.getIncomeQualityTtm() != null) {
            presentCount++;
        }
        return presentCount < MINIMUM_CORE_FUNDAMENTAL_FIELDS;
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    private String blankToEmpty(String value) {
        return value == null ? "" : value;
    }

    private boolean isEtfStock(Stock stock) {
        return stock != null && "ETF".equalsIgnoreCase(blankToEmpty(stock.getAssetType()).trim());
    }

    private boolean isRecentlyListedForPriceHistory(Stock stock, LocalDate today) {
        final LocalDate anchorDate = resolveRecentListingAnchorDate(stock);
        if (anchorDate == null) {
            return false;
        }
        return anchorDate.isAfter(today.minusDays(properties.getRecentListingWindowDays()));
    }

    private boolean isRecentlyListedForFundamentals(Stock stock, LocalDate today) {
        final LocalDate anchorDate = resolveRecentListingAnchorDate(stock);
        if (anchorDate == null) {
            return false;
        }
        return anchorDate.isAfter(today.minusDays(properties.getRecentFundamentalListingWindowDays()));
    }

    private LocalDate resolveRecentListingAnchorDate(Stock stock) {
        if (stock == null) {
            return null;
        }
        return stock.getIpoDate();
    }

    private void refreshStockIpoDateIfMissing(Stock stock, String fmpApiKey) {
        if (stock == null || stock.getId() == null || stock.getIpoDate() != null || !hasText(fmpApiKey)) {
            return;
        }
        final String symbol = hasText(stock.getFinnhubSymbol()) ? stock.getFinnhubSymbol() : stock.getTicker();
        if (!hasText(symbol)) {
            return;
        }
        try {
            final JsonNode profile = getJsonOrNull(
                    "https://financialmodelingprep.com/stable/profile?symbol="
                            + encode(symbol)
                            + "&apikey="
                            + encode(fmpApiKey),
                    symbol
            );
            final JsonNode profileNode = firstValueNode(profile);
            if (profileNode == null || profileNode.isMissingNode() || profileNode.isNull()) {
                return;
            }
            final String ipoDateText = readNullableText(profileNode, "ipoDate");
            if (!hasText(ipoDateText)) {
                return;
            }
            final LocalDate ipoDate = LocalDate.parse(ipoDateText);
            stock.setIpoDate(ipoDate);
            stockPriceSnapshotMapper.updateStockIpoDate(stock.getId(), ipoDate);
        } catch (Exception exception) {
            log.debug("종목 IPO 일자 메타데이터 갱신을 건너뜁니다. symbol={}, reason={}", symbol, rootMessage(exception));
        }
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

    private String rootMessage(Exception exception) {
        Throwable current = exception;
        while (current.getCause() != null) {
            current = current.getCause();
        }
        return current.getMessage() == null
                ? current.getClass().getSimpleName()
                : current.getMessage();
    }

    private SelectedStocks selectStocksForSnapshot(int effectiveLimit) {
        final List<Stock> portfolioStocks = stockPriceSnapshotMapper.findActivePortfolioStocksForSnapshot();
        final List<Stock> nonPortfolioStocks =
                stockPriceSnapshotMapper.findActiveNonPortfolioStocksForSnapshot(effectiveLimit);
        final List<Stock> stocks = new ArrayList<>(portfolioStocks.size() + nonPortfolioStocks.size());
        stocks.addAll(portfolioStocks);
        stocks.addAll(nonPortfolioStocks);
        return new SelectedStocks(stocks, portfolioStocks.size(), nonPortfolioStocks.size());
    }

    private SelectedStocks selectStocksForThirtyDayRecovery(int effectiveLimit) {
        final LocalDate today = LocalDate.now(SNAPSHOT_ZONE);
        final List<Stock> portfolioStocks = filterEligibleThirtyDayRecoveryStocks(
                stockPriceSnapshotMapper.findPortfolioStocksNeedingThirtyDayRecovery(),
                today,
                "portfolio"
        );
        final List<Stock> nonPortfolioStocks = filterEligibleThirtyDayRecoveryStocks(
                stockPriceSnapshotMapper.findNonPortfolioStocksNeedingThirtyDayRecovery(effectiveLimit),
                today,
                "general"
        );
        final List<Stock> stocks = new ArrayList<>(portfolioStocks.size() + nonPortfolioStocks.size());
        stocks.addAll(portfolioStocks);
        stocks.addAll(nonPortfolioStocks);
        return new SelectedStocks(stocks, portfolioStocks.size(), nonPortfolioStocks.size());
    }

    private List<Stock> filterEligibleThirtyDayRecoveryStocks(List<Stock> source, LocalDate today, String bucket) {
        final List<Stock> eligibleStocks = new ArrayList<>();
        final List<String> skippedRecentListings = new ArrayList<>();
        for (Stock stock : source) {
            if (stock == null) {
                continue;
            }
            if (isEtfStock(stock)) {
                continue;
            }
            if (isRecentlyListedForPriceHistory(stock, today)) {
                skippedRecentListings.add(stock.getTicker());
                continue;
            }
            eligibleStocks.add(stock);
        }
        if (!skippedRecentListings.isEmpty()) {
            log.info(
                    "30일 수익률 null 복구 대상에서 최근 상장 종목을 제외했습니다. bucket={}, skippedCount={}, tickers={}",
                    bucket,
                    skippedRecentListings.size(),
                    skippedRecentListings
            );
        }
        return eligibleStocks;
    }

    private BigDecimal findReferencePriceFromSeries(
            Map<LocalDate, BigDecimal> closeByDate,
            LocalDate targetDate,
            LocalDate oldestDate
    ) {
        if (closeByDate.isEmpty()) {
            return null;
        }
        LocalDate current = targetDate;
        while (current != null && !current.isBefore(oldestDate)) {
            final BigDecimal price = closeByDate.get(current);
            if (price != null && price.signum() > 0) {
                return price;
            }
            current = current.minusDays(1);
        }
        return null;
    }

    private record SnapshotData(
            Double currentPrice,
            Double marketCap,
            Double perValue,
            Double epsTtm,
            Double revenueGrowthYoy,
            Double grossMarginTtm,
            Double netMarginTtm,
            Double operatingMarginTtm,
            Double roeTtm,
            Double roaTtm,
            Double roicTtm,
            Double debtToEquityTtm,
            Double currentRatioTtm,
            Double quickRatioTtm,
            Double assetTurnoverTtm,
            Double freeCashFlowYieldTtm,
            Double operatingCashFlowRatioTtm,
            Double incomeQualityTtm
    ) {
        boolean hasFmpFundamentals() {
            return epsTtm != null
                    || revenueGrowthYoy != null
                    || grossMarginTtm != null
                    || netMarginTtm != null
                    || operatingMarginTtm != null
                    || roeTtm != null
                    || roaTtm != null
                    || roicTtm != null
                    || debtToEquityTtm != null
                    || currentRatioTtm != null
                    || quickRatioTtm != null
                    || assetTurnoverTtm != null
                    || freeCashFlowYieldTtm != null
                    || operatingCashFlowRatioTtm != null
                    || incomeQualityTtm != null;
        }
    }

    private record PriceReturns(
            BigDecimal changeRate1d,
            BigDecimal changeRate7d,
            BigDecimal changeRate30d
    ) {
    }

    private record HistoricalPricePoint(
            LocalDate date,
            BigDecimal closePrice,
            String source
    ) {
    }

    private record SelectedStocks(
            List<Stock> stocks,
            int portfolioCount,
            int generalCount
    ) {
    }

    private static final class FinnhubAuthenticationException extends RuntimeException {
        private FinnhubAuthenticationException(int statusCode) {
            super("Finnhub 인증 실패: status=" + statusCode);
        }
    }
}
