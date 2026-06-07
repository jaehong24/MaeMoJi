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

    List<Stock> findActiveStocksForSnapshot(@Param("limit") Integer limit);

    StockPriceSnapshotRecord findLatestSnapshotByStockId(@Param("stockId") Long stockId);

    BigDecimal findPreviousPrice(
            @Param("stockId") Long stockId,
            @Param("snapshotDate") LocalDate snapshotDate
    );

    BigDecimal findReferencePrice(
            @Param("stockId") Long stockId,
            @Param("targetDate") LocalDate targetDate,
            @Param("oldestDate") LocalDate oldestDate
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
            @Param("source") String source
    );
}
