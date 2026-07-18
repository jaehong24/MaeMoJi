package com.maemoji.backend.stock.service;

import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.mapper.StockMapper;
import com.maemoji.backend.stock.provider.StockLogoAvailability;
import com.maemoji.backend.stock.provider.StockLogoProvider;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class StockLogoCacheServiceTest {

    private final StockMapper stockMapper = mock(StockMapper.class);
    private final StockLogoProvider stockLogoProvider =
            mock(StockLogoProvider.class);
    private final StockLogoCacheService service =
            new StockLogoCacheService(stockMapper, stockLogoProvider);

    @Test
    void 로고가있으면외부확인을하지않는다() {
        final Stock stock = stock("AAPL");
        stock.setLogoUrl("https://cached.example/aapl.png");

        service.cacheMissingLogos(List.of(stock));

        assertThat(service.resolveDisplayLogoUrl(stock))
                .isEqualTo("https://cached.example/aapl.png");
        verify(stockLogoProvider, never()).checkLogo("AAPL");
    }

    @Test
    void Fmp로고가존재하면Db에저장한다() {
        final Stock stock = stock("AAPL");
        when(stockLogoProvider.logoUrl("AAPL"))
                .thenReturn("https://financialmodelingprep.com/image-stock/AAPL.png");
        when(stockLogoProvider.checkLogo("AAPL"))
                .thenReturn(StockLogoAvailability.AVAILABLE);

        service.cacheMissingLogos(List.of(stock));

        verify(stockMapper).updateStockLogoCache(
                eq(1L),
                eq("https://financialmodelingprep.com/image-stock/AAPL.png"),
                eq("AVAILABLE"),
                any(OffsetDateTime.class)
        );
    }

    @Test
    void 최근에없는것으로확인한로고는재요청하지않는다() {
        final Stock stock = stock("NOLOGO");
        stock.setLogoStatus("MISSING");
        stock.setLogoCheckedAt(OffsetDateTime.now().minusDays(1));
        when(stockLogoProvider.logoUrl("NOLOGO"))
                .thenReturn("https://financialmodelingprep.com/image-stock/NOLOGO.png");

        service.cacheMissingLogos(List.of(stock));

        assertThat(service.resolveDisplayLogoUrl(stock))
                .isEqualTo("https://financialmodelingprep.com/image-stock/NOLOGO.png");
        verify(stockLogoProvider, never()).checkLogo("NOLOGO");
    }

    @Test
    void 일시적장애는없는로고로캐시하지않는다() {
        final Stock stock = stock("AAPL");
        when(stockLogoProvider.checkLogo("AAPL"))
                .thenReturn(StockLogoAvailability.RETRY);

        service.cacheMissingLogos(List.of(stock));

        verify(stockMapper, never()).updateStockLogoCache(
                any(),
                any(),
                any(),
                any()
        );
    }

    private Stock stock(String symbol) {
        final Stock stock = new Stock();
        stock.setId(1L);
        stock.setSymbol(symbol);
        stock.setTicker(symbol);
        return stock;
    }
}
