package com.maemoji.backend.stock.mapper;

import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.domain.StockMasterUpsertCommand;
import com.maemoji.backend.stock.dto.StockAssetTypeAuditRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.OffsetDateTime;
import java.util.List;

@Mapper
public interface StockMapper {

    List<Stock> searchStocks(
            @Param("keyword") String keyword,
            @Param("compactKeyword") String compactKeyword,
            @Param("limit") int limit
    );

    void upsertStockMasters(
            @Param("stocks") List<StockMasterUpsertCommand> stocks
    );

    int deactivateMissingUsStocks(@Param("syncedAt") OffsetDateTime syncedAt);

    int updateStockLogoCache(
            @Param("id") Long id,
            @Param("logoUrl") String logoUrl,
            @Param("logoStatus") String logoStatus,
            @Param("checkedAt") OffsetDateTime checkedAt
    );

    Stock findStockById(@Param("id") Long id);

    List<Stock> findActiveStocksForRefresh();

    List<StockAssetTypeAuditRow> findSuspiciousAssetTypeStocks(@Param("limit") int limit);

    int countSuspiciousAssetTypeStocks();

    int normalizeAssetTypes();

    Long findStockIdByFinnhubSymbol(@Param("finnhubSymbol") String finnhubSymbol);

    Stock findActiveStockBySymbol(@Param("symbol") String symbol);

    void upsertStockMaster(
            @Param("ticker") String ticker,
            @Param("exchangeCode") String exchangeCode,
            @Param("finnhubSymbol") String finnhubSymbol,
            @Param("nameKo") String nameKo,
            @Param("nameEn") String nameEn,
            @Param("tickerNormalized") String tickerNormalized,
            @Param("nameKoNormalized") String nameKoNormalized,
            @Param("nameEnNormalized") String nameEnNormalized,
            @Param("searchText") String searchText,
            @Param("logoUrl") String logoUrl,
            @Param("marketType") String marketType
    );

    void updateStockMaster(
            @Param("id") Long id,
            @Param("exchangeCode") String exchangeCode,
            @Param("finnhubSymbol") String finnhubSymbol,
            @Param("nameKo") String nameKo,
            @Param("nameEn") String nameEn,
            @Param("tickerNormalized") String tickerNormalized,
            @Param("nameKoNormalized") String nameKoNormalized,
            @Param("nameEnNormalized") String nameEnNormalized,
            @Param("searchText") String searchText,
            @Param("logoUrl") String logoUrl,
            @Param("marketType") String marketType
    );
}
