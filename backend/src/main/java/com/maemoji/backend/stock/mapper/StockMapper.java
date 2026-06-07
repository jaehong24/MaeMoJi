package com.maemoji.backend.stock.mapper;

import com.maemoji.backend.stock.domain.Stock;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface StockMapper {

    List<Stock> searchStocks(@Param("keyword") String keyword);

    Stock findStockById(@Param("id") Long id);

    List<Stock> findActiveStocksForRefresh();

    Long findStockIdByFinnhubSymbol(@Param("finnhubSymbol") String finnhubSymbol);

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
