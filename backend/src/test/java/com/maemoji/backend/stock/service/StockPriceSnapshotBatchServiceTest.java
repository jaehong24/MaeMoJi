package com.maemoji.backend.stock.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.config.PriceSnapshotBatchProperties;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.domain.StockPriceSnapshotRecord;
import com.maemoji.backend.stock.dto.PriceHistoryBackfillResult;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class StockPriceSnapshotBatchServiceTest {

    private final StockPriceSnapshotMapper mapper = mock(StockPriceSnapshotMapper.class);
    private final PriceSnapshotBatchProperties properties = new PriceSnapshotBatchProperties();
    private final StockPriceReturnCalculator returnCalculator = mock(StockPriceReturnCalculator.class);
    private final StockPriceSnapshotBatchService service = spy(new StockPriceSnapshotBatchService(
            mapper,
            properties,
            returnCalculator,
            new ObjectMapper()
    ));

    @Test
    void ensureRecommendationSnapshotSkipsEtfStocks() {
        final Stock etf = stock(101L, "QQQ", "ETF");
        when(mapper.findStockForSnapshotById(101L)).thenReturn(etf);

        final boolean updated = service.ensureRecommendationSnapshot(101L);

        assertThat(updated).isFalse();
        verify(mapper, never()).findLatestSnapshotByStockId(101L);
    }

    @Test
    void ensureRecommendationSnapshotAllowsRecentListingWithoutThirtyDayReturn() {
        final LocalDate today = LocalDate.now();
        final Stock stock = stock(202L, "CRCL", "STOCK");
        stock.setIpoDate(today.minusDays(10));
        final StockPriceSnapshotRecord latest = completeSnapshot(today);
        latest.setChangeRate7d(BigDecimal.valueOf(4.2000));
        latest.setChangeRate30d(null);

        when(mapper.findStockForSnapshotById(202L)).thenReturn(stock);
        when(mapper.findLatestSnapshotByStockId(202L)).thenReturn(latest);
        when(mapper.findOldestSnapshotDateByStockId(202L)).thenReturn(today.minusDays(10));

        final boolean updated = service.ensureRecommendationSnapshot(202L);

        assertThat(updated).isFalse();
        verify(service, never()).backfillHistoricalSnapshotsForStockIds(anyList(), anyInt());
        verify(service, never()).syncLatestSnapshotForStock(202L);
    }

    @Test
    void ensureRecommendationSnapshotRetriesExtendedBackfillForMatureStock() {
        final LocalDate today = LocalDate.now();
        final Stock stock = stock(303L, "AXP", "STOCK");
        stock.setCreatedAt(OffsetDateTime.now().minusDays(180));
        final StockPriceSnapshotRecord latest = completeSnapshot(today);
        latest.setChangeRate7d(BigDecimal.valueOf(2.3000));
        latest.setChangeRate30d(null);

        when(mapper.findStockForSnapshotById(303L)).thenReturn(stock);
        when(mapper.findLatestSnapshotByStockId(303L)).thenReturn(latest, latest, latest);
        when(mapper.findOldestSnapshotDateByStockId(303L)).thenReturn(today.minusDays(90));
        doReturn(0)
                .doReturn(1)
                .when(service).backfillHistoricalSnapshotsForStockIds(eq(List.of(303L)), anyInt());

        final boolean updated = service.ensureRecommendationSnapshot(303L);

        assertThat(updated).isTrue();
        verify(service).backfillHistoricalSnapshotsForStockIds(List.of(303L), properties.getHistoryLookbackDays());
        verify(service).backfillHistoricalSnapshotsForStockIds(List.of(303L), 120);
        verify(service, never()).syncLatestSnapshotForStock(303L);
    }

    @Test
    void ensureRecommendationSnapshotSyncsLatestFirstWhenFundamentalsAreMissing() {
        final LocalDate today = LocalDate.now();
        final Stock stock = stock(404L, "NOW", "STOCK");
        stock.setCreatedAt(OffsetDateTime.now().minusDays(220));

        final StockPriceSnapshotRecord stale = new StockPriceSnapshotRecord();
        stale.setSnapshotDate(today.minusDays(1));
        stale.setCurrentPrice(BigDecimal.valueOf(100.0000));
        stale.setChangeRate7d(BigDecimal.valueOf(1.2000));
        stale.setChangeRate30d(BigDecimal.valueOf(3.4000));
        stale.setSource("FINNHUB_FMP");

        final StockPriceSnapshotRecord refreshed = completeSnapshot(today);

        when(mapper.findStockForSnapshotById(404L)).thenReturn(stock);
        when(mapper.findLatestSnapshotByStockId(404L)).thenReturn(stale, refreshed, refreshed);
        doReturn(true).when(service).syncLatestSnapshotForStock(404L);

        final boolean updated = service.ensureRecommendationSnapshot(404L);

        assertThat(updated).isTrue();
        verify(service).syncLatestSnapshotForStock(404L);
        verify(service, never()).backfillHistoricalSnapshotsForStockIds(anyList(), anyInt());
    }

    @Test
    void nullThirtyDayBackfillPrioritizesPortfolioRecoveryBeforeGeneralStocks() throws Exception {
        final Stock portfolio = stock(501L, "AMD", "STOCK");
        final Stock general = stock(601L, "WMT", "STOCK");

        when(mapper.findPortfolioStocksNeedingThirtyDayRecovery()).thenReturn(List.of(portfolio));
        when(mapper.findNonPortfolioStocksNeedingThirtyDayRecovery(300)).thenReturn(List.of(general));

        doReturn(3)
                .when(service)
                .backfillHistoricalSnapshotsForStock(portfolio, LocalDate.now().minusDays(120), LocalDate.now().minusDays(1), null);

        doReturn(2)
                .when(service)
                .backfillHistoricalSnapshotsForStock(general, LocalDate.now().minusDays(120), LocalDate.now().minusDays(1), null);

        doReturn(true).when(service).syncLatestSnapshotForStock(501L);
        doReturn(true).when(service).syncLatestSnapshotForStock(601L);

        final PriceHistoryBackfillResult result = service.backfillNullThirtyDaySnapshots(300, 120);

        assertThat(result.requestedStockCount()).isEqualTo(2);
        assertThat(result.historyRowCount()).isEqualTo(5);
        assertThat(result.refreshedCurrentSnapshotCount()).isEqualTo(2);
        assertThat(result.failedStockCount()).isZero();
        assertThat(result.failedTickers()).isEmpty();
    }

    @Test
    void nullThirtyDayBackfillSkipsRecentlyListedStocks() throws Exception {
        final LocalDate today = LocalDate.now();
        final Stock recentListing = stock(701L, "SPCX", "STOCK");
        recentListing.setIpoDate(today.minusDays(20));

        final Stock mature = stock(702L, "WMT", "STOCK");
        mature.setIpoDate(today.minusDays(120));

        when(mapper.findPortfolioStocksNeedingThirtyDayRecovery()).thenReturn(List.of(recentListing));
        when(mapper.findNonPortfolioStocksNeedingThirtyDayRecovery(300)).thenReturn(List.of(mature));

        doReturn(4)
                .when(service)
                .backfillHistoricalSnapshotsForStock(mature, LocalDate.now().minusDays(120), LocalDate.now().minusDays(1), null);
        doReturn(true).when(service).syncLatestSnapshotForStock(702L);

        final PriceHistoryBackfillResult result = service.backfillNullThirtyDaySnapshots(300, 120);

        assertThat(result.requestedStockCount()).isEqualTo(1);
        assertThat(result.historyRowCount()).isEqualTo(4);
        assertThat(result.refreshedCurrentSnapshotCount()).isEqualTo(1);
        verify(service, never()).syncLatestSnapshotForStock(701L);
    }

    @Test
    void nullThirtyDayBackfillDoesNotTreatRecentlyImportedStockAsRecentListingWithoutIpoDate() throws Exception {
        final Stock importedRecently = stock(801L, "ABG", "STOCK");
        importedRecently.setCreatedAt(OffsetDateTime.now().minusDays(5));

        when(mapper.findPortfolioStocksNeedingThirtyDayRecovery()).thenReturn(List.of(importedRecently));
        when(mapper.findNonPortfolioStocksNeedingThirtyDayRecovery(300)).thenReturn(List.of());

        doReturn(2)
                .when(service)
                .backfillHistoricalSnapshotsForStock(importedRecently, LocalDate.now().minusDays(120), LocalDate.now().minusDays(1), null);
        doReturn(true).when(service).syncLatestSnapshotForStock(801L);

        final PriceHistoryBackfillResult result = service.backfillNullThirtyDaySnapshots(300, 120);

        assertThat(result.requestedStockCount()).isEqualTo(1);
        assertThat(result.historyRowCount()).isEqualTo(2);
        verify(service).syncLatestSnapshotForStock(801L);
    }

    private Stock stock(Long id, String ticker, String assetType) {
        final Stock stock = new Stock();
        stock.setId(id);
        stock.setTicker(ticker);
        stock.setAssetType(assetType);
        stock.setFinnhubSymbol(ticker);
        return stock;
    }

    private StockPriceSnapshotRecord completeSnapshot(LocalDate snapshotDate) {
        final StockPriceSnapshotRecord snapshot = new StockPriceSnapshotRecord();
        snapshot.setSnapshotDate(snapshotDate);
        snapshot.setCurrentPrice(BigDecimal.valueOf(100.0000));
        snapshot.setChangeRate7d(BigDecimal.valueOf(1.2000));
        snapshot.setChangeRate30d(BigDecimal.valueOf(3.4000));
        snapshot.setEpsTtm(BigDecimal.valueOf(1.1000));
        snapshot.setRevenueGrowthYoy(BigDecimal.valueOf(0.1200));
        snapshot.setOperatingMarginTtm(BigDecimal.valueOf(0.2100));
        snapshot.setRoeTtm(BigDecimal.valueOf(0.1400));
        snapshot.setFreeCashFlowYieldTtm(BigDecimal.valueOf(0.0300));
        snapshot.setIncomeQualityTtm(BigDecimal.valueOf(1.0200));
        snapshot.setSource("FINNHUB_FMP");
        return snapshot;
    }
}
