package com.maemoji.backend.stock.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.config.PriceSnapshotBatchProperties;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.domain.StockPriceSnapshotRecord;
import com.maemoji.backend.stock.mapper.StockPriceSnapshotMapper;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
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
