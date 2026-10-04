package com.maemoji.backend.stock.mapper;

import org.apache.ibatis.builder.xml.XMLMapperBuilder;
import org.apache.ibatis.session.Configuration;
import org.junit.jupiter.api.Test;

import java.io.InputStream;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class StockMapperContractTest {

    @Test
    void nonCommonSecuritiesAreClassifiedBeforeCommonStockKeyword() throws Exception {
        final Configuration configuration = new Configuration();
        final String resource = "mapper/stock/StockMapper.xml";
        try (InputStream input = getClass().getClassLoader().getResourceAsStream(resource)) {
            new XMLMapperBuilder(input, configuration, resource, configuration.getSqlFragments()).parse();
        }

        final String sql = configuration.getMappedStatement(
                        StockMapper.class.getName() + ".findSuspiciousAssetTypeStocks"
                )
                .getBoundSql(Map.of("limit", 50))
                .getSql();

        final int commonStockRule = sql.indexOf("like '%COMMON STOCK%' then 'STOCK'");
        assertThat(commonStockRule).isPositive();
        assertThat(sql.indexOf("like '%FUND COMMON STOCK%' then 'ETF'"))
                .isBetween(0, commonStockRule - 1);
        assertThat(sql.indexOf("like '%PREFERRED STOCK%' then 'ETF'"))
                .isBetween(0, commonStockRule - 1);
        assertThat(sql.indexOf("like '%NOTES DUE%' then 'ETF'"))
                .isBetween(0, commonStockRule - 1);
    }
}
