package com.maemoji.backend.common.startup;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
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
                    add column if not exists source varchar(30)
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_stock_price_snapshots_stock_date
                    on stock_price_snapshots (stock_id, snapshot_date)
                """);
    }
}
