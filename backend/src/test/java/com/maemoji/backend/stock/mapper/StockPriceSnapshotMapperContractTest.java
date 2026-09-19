package com.maemoji.backend.stock.mapper;

import org.apache.ibatis.builder.xml.XMLMapperBuilder;
import org.apache.ibatis.session.Configuration;
import org.junit.jupiter.api.Test;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import static org.assertj.core.api.Assertions.assertThat;

class StockPriceSnapshotMapperContractTest {
    @Test
    void equitiesAndEtfsHaveDisjointSelectionBeforeLimit() throws Exception {
        final Configuration configuration = new Configuration();
        final String resource = "mapper/stock/StockPriceSnapshotMapper.xml";
        try (InputStream input = getClass().getClassLoader().getResourceAsStream(resource)) {
            new XMLMapperBuilder(input, configuration, resource, configuration.getSqlFragments()).parse();
        }
        for (String id : List.of("findActivePortfolioStocksForSnapshot", "findActiveNonPortfolioStocksForSnapshot",
                "findPortfolioStocksNeedingThirtyDayRecovery", "findNonPortfolioStocksNeedingThirtyDayRecovery",
                "findActivePortfolioEtfStocksForSnapshot", "findActiveNonPortfolioEtfStocksForSnapshot")) {
            final String sql = configuration.getMappedStatement(StockPriceSnapshotMapper.class.getName() + "." + id)
                    .getBoundSql(Map.of("limit", 500)).getSql();
            final String predicate = "upper(btrim(coalesce(s.asset_type, ''))) "
                    + (id.contains("Etf") ? "=" : "<>") + " 'ETF'";
            assertThat(sql).contains(predicate);
            assertThat(sql.indexOf(predicate)).isLessThan(sql.indexOf("order by"));
        }
    }
}
