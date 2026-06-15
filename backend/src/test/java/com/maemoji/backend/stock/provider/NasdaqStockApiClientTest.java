package com.maemoji.backend.stock.provider;

import com.maemoji.backend.stock.domain.StockMasterItem;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class NasdaqStockApiClientTest {

    private final NasdaqStockApiClient client = new NasdaqStockApiClient();

    @Test
    void 나스닥주식과Etf를구분하고테스트종목은제외한다() {
        final String content = """
                Symbol|Security Name|Market Category|Test Issue|Financial Status|Round Lot Size|ETF|NextShares
                AAPL|Apple Inc. - Common Stock|Q|N|N|100|N|N
                QQQ|Invesco QQQ Trust|Q|N|N|100|Y|N
                ZTEST|Test Security|Q|Y|N|100|N|N
                File Creation Time: 0616202621:31|||||||
                """;

        final List<StockMasterItem> result = client.parseNasdaqListed(content);

        assertThat(result).extracting(StockMasterItem::symbol)
                .containsExactly("AAPL", "QQQ");
        assertThat(result).extracting(StockMasterItem::assetType)
                .containsExactly("STOCK", "ETF");
        assertThat(result).allMatch(item -> "NASDAQ".equals(item.exchange()));
    }

    @Test
    void 기타거래소코드를표준거래소명으로변환한다() {
        final String content = """
                ACT Symbol|Security Name|Exchange|CQS Symbol|ETF|Round Lot Size|Test Issue|NASDAQ Symbol
                A|Agilent Technologies, Inc. Common Stock|N|A|N|100|N|A
                SPY|SPDR S&P 500 ETF Trust|P|SPY|Y|100|N|SPY
                """;

        final List<StockMasterItem> result = client.parseOtherListed(content);

        assertThat(result).extracting(StockMasterItem::exchange)
                .containsExactly("NYSE", "NYSE_ARCA");
        assertThat(result.get(1).assetType()).isEqualTo("ETF");
    }
}
