package com.maemoji.backend.stock.service;

import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.dto.StockSummaryResponse;
import com.maemoji.backend.stock.mapper.StockMapper;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class StockServiceTest {

    private final StockMapper stockMapper = mock(StockMapper.class);
    private final StockLogoCacheService stockLogoCacheService =
            mock(StockLogoCacheService.class);
    private final StockService stockService =
            new StockService(stockMapper, stockLogoCacheService);

    @Test
    void 빈검색어는Db를조회하지않고빈배열을반환한다() {
        assertThat(stockService.searchStocks("   ")).isEmpty();

        verify(stockMapper, never()).searchStocks("   ", "", 20);
    }

    @Test
    void 검색어를정리하고기본20개를조회한다() {
        final Stock stock = new Stock();
        stock.setId(1L);
        stock.setSymbol("AAPL");
        stock.setTicker("AAPL");
        stock.setExchange("NASDAQ");
        stock.setExchangeCode("NASDAQ");
        stock.setNameKo("애플");
        stock.setNameEn("Apple Inc.");
        stock.setAssetType("STOCK");
        when(stockMapper.searchStocks("애플", "애플", 20)).thenReturn(List.of(stock));

        final List<StockSummaryResponse> result =
                stockService.searchStocks("  애플  ");

        assertThat(result).hasSize(1);
        assertThat(result.get(0).symbol()).isEqualTo("AAPL");
        assertThat(result.get(0).assetType()).isEqualTo("STOCK");
        verify(stockMapper).searchStocks("애플", "애플", 20);
        verify(stockLogoCacheService).cacheMissingLogos(List.of(stock));
    }

    @Test
    void 띄어쓰기없는검색어도공백제거키워드로함께조회한다() {
        when(stockMapper.searchStocks("엑스에너지", "엑스에너지", 20))
                .thenReturn(List.of());

        stockService.searchStocks("엑스에너지");

        verify(stockMapper).searchStocks("엑스에너지", "엑스에너지", 20);
    }

    @Test
    void 띄어쓰기있는검색어는공백제거키워드도같이전달한다() {
        when(stockMapper.searchStocks("엑스 에너지", "엑스에너지", 20))
                .thenReturn(List.of());

        stockService.searchStocks(" 엑스 에너지 ");

        verify(stockMapper).searchStocks("엑스 에너지", "엑스에너지", 20);
    }
}
