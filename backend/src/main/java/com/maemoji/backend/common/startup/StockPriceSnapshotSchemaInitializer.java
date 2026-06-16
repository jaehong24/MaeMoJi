package com.maemoji.backend.common.startup;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class StockPriceSnapshotSchemaInitializer implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    public StockPriceSnapshotSchemaInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(ApplicationArguments args) {
        jdbcTemplate.execute("""
                alter table stock_price_snapshots
                    add column if not exists current_price numeric(15, 4),
                    add column if not exists change_rate_1d numeric(8, 4),
                    add column if not exists change_rate_7d numeric(8, 4),
                    add column if not exists change_rate_30d numeric(8, 4),
                    add column if not exists market_cap numeric(20, 2),
                    add column if not exists per_value numeric(12, 4),
                    add column if not exists eps_ttm numeric(12, 4),
                    add column if not exists revenue_growth_yoy numeric(12, 4),
                    add column if not exists gross_margin_ttm numeric(12, 4),
                    add column if not exists net_margin_ttm numeric(12, 4),
                    add column if not exists operating_margin_ttm numeric(12, 4),
                    add column if not exists roe_ttm numeric(12, 4),
                    add column if not exists roa_ttm numeric(12, 4),
                    add column if not exists roic_ttm numeric(12, 4),
                    add column if not exists debt_to_equity_ttm numeric(12, 4),
                    add column if not exists current_ratio_ttm numeric(12, 4),
                    add column if not exists quick_ratio_ttm numeric(12, 4),
                    add column if not exists asset_turnover_ttm numeric(12, 4),
                    add column if not exists free_cash_flow_yield_ttm numeric(12, 4),
                    add column if not exists operating_cash_flow_ratio_ttm numeric(12, 4),
                    add column if not exists income_quality_ttm numeric(12, 4),
                    add column if not exists source varchar(30)
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_stock_price_snapshots_stock_date
                    on stock_price_snapshots (stock_id, snapshot_date)
                """);
    }
}
