package com.maemoji.backend.stock.mapper;

import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.domain.StockPriceSnapshotRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Mapper
public interface StockPriceSnapshotMapper {

    List<Stock> findActivePortfolioStocksForSnapshot();

    List<Stock> findActiveNonPortfolioStocksForSnapshot(@Param("limit") Integer limit);

    List<Stock> findActivePortfolioEtfStocksForSnapshot();

    List<Stock> findActiveNonPortfolioEtfStocksForSnapshot(@Param("limit") Integer limit);

    List<Stock> findPortfolioStocksNeedingThirtyDayRecovery();

    List<Stock> findNonPortfolioStocksNeedingThirtyDayRecovery(@Param("limit") Integer limit);

    Stock findStockForSnapshotById(@Param("stockId") Long stockId);

    List<Long> findActivePortfolioStockIds();

    StockPriceSnapshotRecord findLatestSnapshotByStockId(@Param("stockId") Long stockId);

    java.time.LocalDate findOldestSnapshotDateByStockId(@Param("stockId") Long stockId);

    int updateStockIpoDate(
            @Param("stockId") Long stockId,
            @Param("ipoDate") LocalDate ipoDate
    );

    BigDecimal findPreviousPrice(
            @Param("stockId") Long stockId,
            @Param("snapshotDate") LocalDate snapshotDate
    );

    BigDecimal findReferencePrice(
            @Param("stockId") Long stockId,
            @Param("targetDate") LocalDate targetDate,
            @Param("oldestDate") LocalDate oldestDate
    );

    BigDecimal findReferencePriceForward(
            @Param("stockId") Long stockId,
            @Param("targetDate") LocalDate targetDate,
            @Param("newestDate") LocalDate newestDate
    );

    void upsertPriceSnapshot(
            @Param("stockId") Long stockId,
            @Param("snapshotDate") LocalDate snapshotDate,
            @Param("currentPrice") BigDecimal currentPrice,
            @Param("changeRate1d") BigDecimal changeRate1d,
            @Param("changeRate7d") BigDecimal changeRate7d,
            @Param("changeRate30d") BigDecimal changeRate30d,
            @Param("marketCap") BigDecimal marketCap,
            @Param("perValue") BigDecimal perValue,
            @Param("epsTtm") BigDecimal epsTtm,
            @Param("revenueGrowthYoy") BigDecimal revenueGrowthYoy,
            @Param("grossMarginTtm") BigDecimal grossMarginTtm,
            @Param("netMarginTtm") BigDecimal netMarginTtm,
            @Param("operatingMarginTtm") BigDecimal operatingMarginTtm,
            @Param("roeTtm") BigDecimal roeTtm,
            @Param("roaTtm") BigDecimal roaTtm,
            @Param("roicTtm") BigDecimal roicTtm,
            @Param("debtToEquityTtm") BigDecimal debtToEquityTtm,
            @Param("currentRatioTtm") BigDecimal currentRatioTtm,
            @Param("quickRatioTtm") BigDecimal quickRatioTtm,
            @Param("assetTurnoverTtm") BigDecimal assetTurnoverTtm,
            @Param("freeCashFlowYieldTtm") BigDecimal freeCashFlowYieldTtm,
            @Param("operatingCashFlowRatioTtm") BigDecimal operatingCashFlowRatioTtm,
            @Param("incomeQualityTtm") BigDecimal incomeQualityTtm,
            @Param("source") String source
    );

    void upsertHistoricalPriceSnapshot(
            @Param("stockId") Long stockId,
            @Param("snapshotDate") LocalDate snapshotDate,
            @Param("currentPrice") BigDecimal currentPrice,
            @Param("changeRate1d") BigDecimal changeRate1d,
            @Param("changeRate7d") BigDecimal changeRate7d,
            @Param("changeRate30d") BigDecimal changeRate30d,
            @Param("source") String source
    );
}
