package com.maemoji.backend.stock.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.domain.StockMasterItem;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class FmpStockApiClientTest {

    private final FmpStockApiClient client =
            new FmpStockApiClient(new ObjectMapper());

    @Test
    void 미국거래소주식만파싱한다() {
        final String json = """
                [
                  {
                    "symbol": "AAPL",
                    "name": "Apple Inc.",
                    "exchange": "NASDAQ Global Select",
                    "exchangeShortName": "NASDAQ",
                    "type": "stock",
                    "currency": "USD"
                  },
                  {
                    "symbol": "005930.KS",
                    "name": "Samsung Electronics",
                    "exchangeShortName": "KSC",
                    "type": "stock"
                  }
                ]
                """;

        final List<StockMasterItem> result = client.parseItems(json, false);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).symbol()).isEqualTo("AAPL");
        assertThat(result.get(0).assetType()).isEqualTo("STOCK");
    }

    @Test
    void Etf목록은Etf로강제분류한다() {
        final String json = """
                [
                  {
                    "symbol": "VOO",
                    "name": "Vanguard S&P 500 ETF",
                    "exchangeShortName": "NYSE Arca"
                  }
                ]
                """;

        final List<StockMasterItem> result = client.parseItems(json, true);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).assetType()).isEqualTo("ETF");
        assertThat(result.get(0).exchange()).isEqualTo("NYSE_ARCA");
    }
}
