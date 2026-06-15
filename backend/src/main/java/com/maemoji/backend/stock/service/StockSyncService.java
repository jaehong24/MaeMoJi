package com.maemoji.backend.stock.service;

import com.maemoji.backend.stock.config.StockMasterSyncProperties;
import com.maemoji.backend.stock.domain.StockMasterItem;
import com.maemoji.backend.stock.domain.StockMasterUpsertCommand;
import com.maemoji.backend.stock.dto.StockMasterSyncResult;
import com.maemoji.backend.stock.mapper.StockMapper;
import com.maemoji.backend.stock.provider.FmpStockApiClient;
import com.maemoji.backend.stock.provider.NasdaqStockApiClient;
import com.maemoji.backend.stock.provider.StockApiClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

@Service
public class StockSyncService {

    private static final Logger log = LoggerFactory.getLogger(StockSyncService.class);
    private static final int MINIMUM_SAFE_UNIVERSE_SIZE = 1_000;

    private final StockMapper stockMapper;
    private final StockService stockService;
    private final StockKoreanNameService stockKoreanNameService;
    private final StockMasterSyncProperties properties;
    private final FmpStockApiClient fmpClient;
    private final NasdaqStockApiClient nasdaqClient;
    private final AtomicBoolean running = new AtomicBoolean(false);

    public StockSyncService(
            StockMapper stockMapper,
            StockService stockService,
            StockKoreanNameService stockKoreanNameService,
            StockMasterSyncProperties properties,
            FmpStockApiClient fmpClient,
            NasdaqStockApiClient nasdaqClient
    ) {
        this.stockMapper = stockMapper;
        this.stockService = stockService;
        this.stockKoreanNameService = stockKoreanNameService;
        this.properties = properties;
        this.fmpClient = fmpClient;
        this.nasdaqClient = nasdaqClient;
    }

    @Scheduled(cron = "${maemoji.batch.stock-master.cron:0 0 4 * * *}")
    public void syncOnSchedule() {
        if (!properties.isEnabled()) {
            return;
        }
        try {
            syncAll();
        } catch (Exception exception) {
            log.error("미국 종목 마스터 자동 동기화에 실패했습니다.", exception);
        }
    }

    public StockMasterSyncResult syncAll() {
        if (!running.compareAndSet(false, true)) {
            throw new IllegalStateException("미국 종목 마스터 동기화가 이미 실행 중입니다.");
        }

        final OffsetDateTime startedAt = OffsetDateTime.now(ZoneOffset.UTC);
        try {
            final ProviderResult providerResult = fetchWithFallback();
            final List<StockMasterItem> items = deduplicate(providerResult.items());
            if (items.size() < MINIMUM_SAFE_UNIVERSE_SIZE) {
                throw new IllegalStateException(
                        "외부 종목 목록이 비정상적으로 적어 DB 반영을 중단합니다. count=" + items.size()
                );
            }

            final List<StockMasterUpsertCommand> commands = items.stream()
                    .map(item -> toCommand(item, startedAt))
                    .toList();
            final int batchSize = Math.max(100, properties.getBatchSize());
            int syncedCount = 0;
            for (int start = 0; start < commands.size(); start += batchSize) {
                final int end = Math.min(start + batchSize, commands.size());
                final List<StockMasterUpsertCommand> batch = commands.subList(start, end);
                stockMapper.upsertStockMasters(batch);
                syncedCount += batch.size();
                log.info(
                        "미국 종목 마스터 저장 중입니다. provider={}, progress={}/{}",
                        providerResult.provider(),
                        syncedCount,
                        commands.size()
                );
            }

            final int deactivatedCount = stockMapper.deactivateMissingUsStocks(startedAt);
            final OffsetDateTime finishedAt = OffsetDateTime.now(ZoneOffset.UTC);
            log.info(
                    "미국 종목 마스터 동기화를 완료했습니다. provider={}, fetched={}, synced={}, deactivated={}",
                    providerResult.provider(),
                    items.size(),
                    syncedCount,
                    deactivatedCount
            );
            return new StockMasterSyncResult(
                    "SUCCESS",
                    providerResult.provider(),
                    items.size(),
                    syncedCount,
                    deactivatedCount,
                    startedAt,
                    finishedAt
            );
        } finally {
            running.set(false);
        }
    }

    private ProviderResult fetchWithFallback() {
        if (fmpClient.isAvailable()) {
            try {
                final List<StockMasterItem> items = fmpClient.fetchUsStocksAndEtfs();
                if (!items.isEmpty()) {
                    return new ProviderResult(fmpClient.providerName(), items);
                }
                log.warn("FMP 종목 목록이 비어 있어 Nasdaq Provider로 전환합니다.");
            } catch (Exception exception) {
                log.warn(
                        "FMP 종목 목록 조회에 실패해 Nasdaq Provider로 전환합니다. reason={}",
                        rootMessage(exception)
                );
            }
        } else {
            log.info("FMP_API_KEY가 없어 Nasdaq Provider를 사용합니다.");
        }

        if (!nasdaqClient.isAvailable()) {
            throw new IllegalStateException("사용 가능한 미국 종목 Provider가 없습니다.");
        }
        return new ProviderResult(
                nasdaqClient.providerName(),
                nasdaqClient.fetchUsStocksAndEtfs()
        );
    }

    private List<StockMasterItem> deduplicate(List<StockMasterItem> items) {
        final Map<String, StockMasterItem> bySymbol = new LinkedHashMap<>();
        for (StockMasterItem item : items) {
            final String symbol = normalizeSymbol(item.symbol());
            if (symbol.isBlank() || item.nameEn() == null || item.nameEn().isBlank()) {
                continue;
            }
            bySymbol.merge(
                    symbol,
                    new StockMasterItem(
                            symbol,
                            item.nameEn().trim(),
                            item.exchange(),
                            item.assetType(),
                            item.currency(),
                            item.country(),
                            item.sector(),
                            item.industry(),
                            item.logoUrl()
                    ),
                    this::preferRicherItem
            );
        }
        return new ArrayList<>(bySymbol.values());
    }

    private StockMasterItem preferRicherItem(
            StockMasterItem existing,
            StockMasterItem candidate
    ) {
        if ("ETF".equals(candidate.assetType()) && !"ETF".equals(existing.assetType())) {
            return candidate;
        }
        return existing;
    }

    private StockMasterUpsertCommand toCommand(
            StockMasterItem item,
            OffsetDateTime syncedAt
    ) {
        final String nameKo = stockKoreanNameService.resolveNameKo(
                item.symbol(),
                item.nameEn(),
                item.assetType()
        );
        final StockService.NormalizedStockFields normalized =
                stockService.normalizeStockFields(item.symbol(), nameKo, item.nameEn());
        return new StockMasterUpsertCommand(
                item.symbol(),
                item.nameEn().trim(),
                nameKo,
                normalizeExchange(item.exchange()),
                "ETF".equalsIgnoreCase(item.assetType()) ? "ETF" : "STOCK",
                blankFallback(item.currency(), "USD"),
                blankFallback(item.country(), "US"),
                blankToNull(item.sector()),
                blankToNull(item.industry()),
                normalized.tickerNormalized(),
                normalized.nameKoNormalized(),
                normalized.nameEnNormalized(),
                normalized.searchText(),
                blankToNull(item.logoUrl()),
                syncedAt
        );
    }

    private String normalizeSymbol(String symbol) {
        return symbol == null ? "" : symbol.trim().toUpperCase(Locale.ROOT);
    }

    private String normalizeExchange(String exchange) {
        return exchange == null || exchange.isBlank()
                ? "UNKNOWN"
                : exchange.trim().toUpperCase(Locale.ROOT);
    }

    private String blankFallback(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
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

    private record ProviderResult(String provider, List<StockMasterItem> items) {
    }
}
