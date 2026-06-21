package com.maemoji.backend.stock.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@EnabledIfEnvironmentVariable(named = "LIVE_SNAPSHOT_VALIDATION", matches = "true")
class StockPriceSnapshotLiveValidationTest {

    private static final ZoneId SNAPSHOT_ZONE = ZoneId.of("Asia/Seoul");
    private static final List<String> VALIDATION_SYMBOLS = List.of(
            "META",
            "MSFT",
            "JPM"
    );
    private static final List<String> DIVERSE_VALIDATION_SYMBOLS = List.of(
            "MCD",
            "COST",
            "NEE",
            "XOM",
            "KO",
            "AMD",
            "UNH"
    );
    private static final List<String> SAMPLE_SET_BACKFILL_SYMBOLS = List.of(
            "PG",
            "GS",
            "HD",
            "DELL",
            "CAT",
            "AVGO",
            "PLTR",
            "ARM"
    );
    private static final List<String> HISTORY_VALIDATION_SYMBOLS = List.of(
            "META",
            "MCD",
            "NEE"
    );
    private static final List<String> SAMPLE_SET_PRICE_BACKFILL_SYMBOLS = List.of(
            "AMAT",
            "ADBE",
            "AMD",
            "ARM",
            "AVGO",
            "CAT",
            "CRM",
            "DELL",
            "GE",
            "GS",
            "HD",
            "INTC",
            "JPM",
            "MSFT",
            "NOW",
            "ORCL",
            "PANW",
            "PG",
            "PLTR",
            "QCOM",
            "TXN",
            "UNH",
            "WMT",
            "XOM"
    );
    private static final List<String> MISSING_PRICE_FLOW_SAMPLE_SYMBOLS = List.of(
            "TM",
            "NVS",
            "AZN",
            "LIN",
            "SAP"
    );

    @Autowired
    private StockPriceSnapshotBatchService stockPriceSnapshotBatchService;

    @Autowired
    private DataSource dataSource;

    @Test
    void fillsCoreFundamentalsForNewlyTrackedStocks() throws Exception {
        for (String symbol : VALIDATION_SYMBOLS) {
            final Long stockId = findStockId(symbol);
            assertThat(stockId)
                    .as("stockId for %s", symbol)
                    .isNotNull();

            final boolean synced = stockPriceSnapshotBatchService.syncLatestSnapshotForStock(stockId);
            assertThat(synced)
                    .as("snapshot sync result for %s", symbol)
                    .isTrue();

            final SnapshotValidationRow latestSnapshot = findLatestSnapshot(symbol);
            assertThat(latestSnapshot)
                    .as("latest snapshot row for %s", symbol)
                    .isNotNull();
            assertThat(latestSnapshot.snapshotDate())
                    .as("latest snapshot date for %s", symbol)
                    .isEqualTo(LocalDate.now(SNAPSHOT_ZONE));
            assertThat(latestSnapshot.source())
                    .as("latest snapshot source for %s", symbol)
                    .isEqualTo("FINNHUB_FMP");
            assertThat(latestSnapshot.presentCoreFieldCount())
                    .as("present core fundamentals for %s", symbol)
                    .isGreaterThanOrEqualTo(4);
        }
    }

    @Test
    void backfillsAdditionalSampleSetStocksForTuning() throws Exception {
        for (String symbol : SAMPLE_SET_BACKFILL_SYMBOLS) {
            final Long stockId = findStockId(symbol);
            assertThat(stockId)
                    .as("stockId for %s", symbol)
                    .isNotNull();

            final boolean synced = stockPriceSnapshotBatchService.syncLatestSnapshotForStock(stockId);
            assertThat(synced)
                    .as("snapshot sync result for %s", symbol)
                    .isTrue();

            final SnapshotValidationRow latestSnapshot = findLatestSnapshot(symbol);
            assertThat(latestSnapshot)
                    .as("latest snapshot row for %s", symbol)
                    .isNotNull();
            assertThat(latestSnapshot.snapshotDate())
                    .as("latest snapshot date for %s", symbol)
                    .isEqualTo(LocalDate.now(SNAPSHOT_ZONE));
        }
    }

    @Test
    void fillsCoreFundamentalsForDiverseNewlyTrackedStocks() throws Exception {
        for (String symbol : DIVERSE_VALIDATION_SYMBOLS) {
            final Long stockId = findStockId(symbol);
            assertThat(stockId)
                    .as("stockId for %s", symbol)
                    .isNotNull();

            final boolean synced = stockPriceSnapshotBatchService.syncLatestSnapshotForStock(stockId);
            assertThat(synced)
                    .as("snapshot sync result for %s", symbol)
                    .isTrue();

            final SnapshotValidationRow latestSnapshot = findLatestSnapshot(symbol);
            assertThat(latestSnapshot)
                    .as("latest snapshot row for %s", symbol)
                    .isNotNull();
            assertThat(latestSnapshot.snapshotDate())
                    .as("latest snapshot date for %s", symbol)
                    .isEqualTo(LocalDate.now(SNAPSHOT_ZONE));
            assertThat(latestSnapshot.source())
                    .as("latest snapshot source for %s", symbol)
                    .isEqualTo("FINNHUB_FMP");
            assertThat(latestSnapshot.presentCoreFieldCount())
                    .as("present core fundamentals for %s", symbol)
                    .isGreaterThanOrEqualTo(4);
        }
    }

    @Test
    void backfillsThirtyDayHistoryAndEnablesPriceFlowScores() throws Exception {
        final List<Long> stockIds = HISTORY_VALIDATION_SYMBOLS.stream()
                .map(symbol -> {
                    try {
                        return findStockId(symbol);
                    } catch (Exception exception) {
                        throw new IllegalStateException(exception);
                    }
                })
                .toList();

        final int savedRows = stockPriceSnapshotBatchService.backfillHistoricalSnapshotsForStockIds(stockIds, 45);
        assertThat(savedRows).isGreaterThan(0);

        for (String symbol : HISTORY_VALIDATION_SYMBOLS) {
            final SnapshotValidationRow latestSnapshot = findLatestSnapshot(symbol);
            assertThat(latestSnapshot)
                    .as("latest snapshot row for %s", symbol)
                    .isNotNull();
            assertThat(latestSnapshot.snapshotDate())
                    .as("latest snapshot date for %s", symbol)
                    .isEqualTo(LocalDate.now(SNAPSHOT_ZONE));
            assertThat(latestSnapshot.changeRate30d())
                    .as("30 day return for %s", symbol)
                    .isNotNull();
        }
    }

    @Test
    void backfillsThirtyDayHistoryForActivePortfolioStocks() throws Exception {
        final List<Long> activePortfolioStockIds = findActivePortfolioStockIds();
        if (activePortfolioStockIds.isEmpty()) {
            return;
        }

        final int savedRows = stockPriceSnapshotBatchService.backfillHistoricalSnapshotsForStockIds(
                activePortfolioStockIds,
                45
        );
        assertThat(savedRows).isGreaterThan(0);

        final int stocksWithThirtyDayReturn = countActivePortfolioStocksWithThirtyDayReturn();
        assertThat(stocksWithThirtyDayReturn)
                .as("active portfolio stocks with 30 day return")
                .isGreaterThan(0);
    }

    @Test
    void backfillsThirtyDayHistoryForExpandedSampleSet() throws Exception {
        final List<Long> stockIds = SAMPLE_SET_PRICE_BACKFILL_SYMBOLS.stream()
                .map(symbol -> {
                    try {
                        return findStockId(symbol);
                    } catch (Exception exception) {
                        throw new IllegalStateException(exception);
                    }
                })
                .toList();

        final int savedRows = stockPriceSnapshotBatchService.backfillHistoricalSnapshotsForStockIds(stockIds, 45);
        assertThat(savedRows).isGreaterThan(0);

        for (String symbol : SAMPLE_SET_PRICE_BACKFILL_SYMBOLS) {
            final SnapshotValidationRow latestSnapshot = findLatestSnapshot(symbol);
            assertThat(latestSnapshot)
                    .as("latest snapshot row for %s", symbol)
                    .isNotNull();
            assertThat(latestSnapshot.changeRate30d())
                    .as("30 day return for %s", symbol)
                    .isNotNull();
        }
    }

    @Test
    void backfillsThirtyDayHistoryForMissingPriceFlowSampleSet() throws Exception {
        final List<Long> stockIds = MISSING_PRICE_FLOW_SAMPLE_SYMBOLS.stream()
                .map(symbol -> {
                    try {
                        return findStockId(symbol);
                    } catch (Exception exception) {
                        throw new IllegalStateException(exception);
                    }
                })
                .toList();

        final int savedRows = stockPriceSnapshotBatchService.backfillHistoricalSnapshotsForStockIds(stockIds, 45);
        assertThat(savedRows).isGreaterThan(0);

        for (String symbol : MISSING_PRICE_FLOW_SAMPLE_SYMBOLS) {
            final SnapshotValidationRow latestSnapshot = findLatestSnapshot(symbol);
            assertThat(latestSnapshot)
                    .as("latest snapshot row for %s", symbol)
                    .isNotNull();
            assertThat(latestSnapshot.changeRate30d())
                    .as("30 day return for %s", symbol)
                    .isNotNull();
        }
    }

    private Long findStockId(String symbol) throws Exception {
        final String sql = """
                select id
                from stocks
                where symbol = ?
                limit 1
                """;
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, symbol);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                return resultSet.getLong("id");
            }
        }
    }

    private SnapshotValidationRow findLatestSnapshot(String symbol) throws Exception {
        final String sql = """
                select
                    p.snapshot_date,
                    p.source,
                    p.change_rate_30d,
                    p.eps_ttm,
                    p.revenue_growth_yoy,
                    p.operating_margin_ttm,
                    p.roe_ttm,
                    p.free_cash_flow_yield_ttm,
                    p.income_quality_ttm
                from stocks s
                join stock_price_snapshots p on p.stock_id = s.id
                where s.symbol = ?
                order by p.snapshot_date desc, p.id desc
                limit 1
                """;
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, symbol);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                int presentCoreFieldCount = 0;
                if (resultSet.getBigDecimal("eps_ttm") != null) {
                    presentCoreFieldCount++;
                }
                if (resultSet.getBigDecimal("revenue_growth_yoy") != null) {
                    presentCoreFieldCount++;
                }
                if (resultSet.getBigDecimal("operating_margin_ttm") != null) {
                    presentCoreFieldCount++;
                }
                if (resultSet.getBigDecimal("roe_ttm") != null) {
                    presentCoreFieldCount++;
                }
                if (resultSet.getBigDecimal("free_cash_flow_yield_ttm") != null) {
                    presentCoreFieldCount++;
                }
                if (resultSet.getBigDecimal("income_quality_ttm") != null) {
                    presentCoreFieldCount++;
                }
                return new SnapshotValidationRow(
                        resultSet.getDate("snapshot_date").toLocalDate(),
                        resultSet.getString("source"),
                        resultSet.getBigDecimal("change_rate_30d") == null
                                ? null
                                : resultSet.getBigDecimal("change_rate_30d").doubleValue(),
                        presentCoreFieldCount
                );
            }
        }
    }

    private List<Long> findActivePortfolioStockIds() throws Exception {
        final String sql = """
                select distinct stock_id
                from portfolio_items
                where is_active = true
                order by stock_id
                """;
        final List<Long> stockIds = new ArrayList<>();
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                stockIds.add(resultSet.getLong("stock_id"));
            }
        }
        return stockIds;
    }

    private int countActivePortfolioStocksWithThirtyDayReturn() throws Exception {
        final String sql = """
                select count(*) as count
                from (
                    select distinct on (pi.stock_id)
                        pi.stock_id,
                        sps.change_rate_30d
                    from portfolio_items pi
                    join stock_price_snapshots sps on sps.stock_id = pi.stock_id
                    where pi.is_active = true
                    order by pi.stock_id, sps.snapshot_date desc, sps.id desc
                ) latest
                where latest.change_rate_30d is not null
                """;
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            resultSet.next();
            return resultSet.getInt("count");
        }
    }

    private record SnapshotValidationRow(
            LocalDate snapshotDate,
            String source,
            Double changeRate30d,
            int presentCoreFieldCount
    ) {
    }
}
