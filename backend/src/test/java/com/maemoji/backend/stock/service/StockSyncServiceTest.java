package com.maemoji.backend.stock.service;

import com.maemoji.backend.stock.config.StockMasterSyncProperties;
import com.maemoji.backend.stock.domain.StockMasterItem;
import com.maemoji.backend.stock.domain.StockMasterUpsertCommand;
import com.maemoji.backend.stock.dto.StockMasterSyncResult;
import com.maemoji.backend.stock.mapper.StockMapper;
import com.maemoji.backend.stock.provider.FmpStockApiClient;
import com.maemoji.backend.stock.provider.NasdaqStockApiClient;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentCaptor.forClass;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class StockSyncServiceTest {

    private final StockMapper stockMapper = mock(StockMapper.class);
    private final StockService stockService = new StockService(
            stockMapper,
            mock(StockLogoCacheService.class)
    );
    private final StockKoreanNameService stockKoreanNameService =
            new StockKoreanNameService();
    private final StockMasterSyncProperties properties =
            new StockMasterSyncProperties();
    private final FmpStockApiClient fmpClient = mock(FmpStockApiClient.class);
    private final NasdaqStockApiClient nasdaqClient =
            mock(NasdaqStockApiClient.class);

    @Test
    void Fmp가실패하면Nasdaq으로전환하고분할저장한다() {
        properties.setBatchSize(500);
        when(fmpClient.isAvailable()).thenReturn(true);
        when(fmpClient.fetchUsStocksAndEtfs())
                .thenThrow(new IllegalStateException("status=402"));
        when(nasdaqClient.isAvailable()).thenReturn(true);
        when(nasdaqClient.providerName()).thenReturn("NASDAQ_SYMBOL_DIRECTORY");
        when(nasdaqClient.fetchUsStocksAndEtfs()).thenReturn(sampleItems(1_001));
        when(stockMapper.deactivateMissingUsStocks(any())).thenReturn(3);

        final StockSyncService service = new StockSyncService(
                stockMapper,
                stockService,
                stockKoreanNameService,
                properties,
                fmpClient,
                nasdaqClient
        );

        final StockMasterSyncResult result = service.syncAll();

        assertThat(result.provider()).isEqualTo("NASDAQ_SYMBOL_DIRECTORY");
        assertThat(result.syncedCount()).isEqualTo(1_001);
        assertThat(result.deactivatedCount()).isEqualTo(3);
        verify(stockMapper, times(3)).upsertStockMasters(any());
        verify(stockMapper).deactivateMissingUsStocks(any());

        @SuppressWarnings("unchecked")
        final org.mockito.ArgumentCaptor<List<StockMasterUpsertCommand>> captor =
                forClass(List.class);
        verify(stockMapper, times(3)).upsertStockMasters(captor.capture());
        assertThat(captor.getAllValues().get(0).get(0).nameKo()).isEqualTo("애플");
    }

    private List<StockMasterItem> sampleItems(int count) {
        return IntStream.range(0, count)
                .mapToObj(index -> new StockMasterItem(
                        index == 0 ? "AAPL" : "T" + index,
                        "Test Company " + index,
                        "NASDAQ",
                        "STOCK",
                        "USD",
                        "US",
                        null,
                        null,
                        null
                ))
                .toList();
    }
}
