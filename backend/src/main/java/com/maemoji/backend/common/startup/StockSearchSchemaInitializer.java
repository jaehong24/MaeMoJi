package com.maemoji.backend.common.startup;

import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/// 로컬 개발 DB가 최신 검색 마스터 스키마를 항상 갖도록 시작 시점에 보정합니다.
///
/// 현재 프로젝트는 별도 마이그레이션 도구를 아직 붙이지 않았기 때문에,
/// 개발 단계에서는 최소한의 컬럼/인덱스를 자동 보정해주는 편이 안전합니다.
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class StockSearchSchemaInitializer implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    public StockSearchSchemaInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(org.springframework.boot.ApplicationArguments args) {
        jdbcTemplate.execute("""
                alter table stocks
                    add column if not exists symbol varchar(30),
                    add column if not exists exchange varchar(30),
                    add column if not exists asset_type varchar(30),
                    add column if not exists currency varchar(10),
                    add column if not exists country varchar(10),
                    add column if not exists sector text,
                    add column if not exists industry text,
                    add column if not exists ipo_date date,
                    add column if not exists last_master_sync_at timestamptz,
                    add column if not exists logo_status varchar(20),
                    add column if not exists logo_checked_at timestamptz
                """);

        jdbcTemplate.execute("""
                with ranked_symbols as (
                    select
                        id,
                        upper(trim(ticker)) as base_symbol,
                        row_number() over (
                            partition by upper(trim(ticker))
                            order by id
                        ) as symbol_order,
                        count(*) over (
                            partition by upper(trim(ticker))
                        ) as symbol_count
                    from stocks
                )
                update stocks s
                set symbol = case
                    when ranked.symbol_count = 1 then ranked.base_symbol
                    when ranked.symbol_order = 1 then ranked.base_symbol
                    else left(ranked.base_symbol, 20) || '@' || s.id
                end
                from ranked_symbols ranked
                where ranked.id = s.id
                  and (
                      s.symbol is null
                      or trim(s.symbol) = ''
                      or ranked.symbol_count > 1
                  )
                """);

        jdbcTemplate.execute("""
                update stocks
                set
                    exchange = coalesce(nullif(trim(exchange), ''), exchange_code),
                    asset_type = coalesce(
                        nullif(trim(asset_type), ''),
                        case
                            when upper(coalesce(market_type, '')) like '%ETF%' then 'ETF'
                            else 'STOCK'
                        end
                    ),
                    currency = coalesce(nullif(trim(currency), ''), 'USD'),
                    country = coalesce(nullif(trim(country), ''), 'US')
                where exchange is null
                   or asset_type is null
                   or currency is null
                   or country is null
                """);

        jdbcTemplate.execute("""
                alter table stocks
                    alter column symbol set not null,
                    alter column exchange set not null,
                    alter column asset_type set not null,
                    alter column currency set not null,
                    alter column country set not null
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_stocks_symbol
                    on stocks (symbol)
                """);

        // 공식 상장 종목 파일에는 설명이 긴 종목명이 많아서 text 타입으로 넉넉하게 맞춥니다.
        jdbcTemplate.execute("""
                alter table stocks
                    alter column name_ko type text,
                    alter column name_en type text
                """);

        jdbcTemplate.execute("""
                alter table stocks
                    add column if not exists ticker_normalized varchar(30),
                    add column if not exists name_ko_normalized text,
                    add column if not exists name_en_normalized text,
                    add column if not exists search_text text
                """);

        jdbcTemplate.execute("""
                alter table stocks
                    alter column name_ko_normalized type text,
                    alter column name_en_normalized type text
                """);

        jdbcTemplate.execute("""
                update stocks
                set name_ko = case symbol
                    when 'AAPL' then '애플'
                    when 'TSLA' then '테슬라'
                    when 'NVDA' then '엔비디아'
                    when 'MSFT' then '마이크로소프트'
                    when 'GOOGL' then '구글'
                    when 'GOOG' then '구글'
                    when 'AMZN' then '아마존'
                    when 'META' then '메타'
                    when 'NFLX' then '넷플릭스'
                    when 'QQQ' then '큐큐큐'
                    when 'SPY' then '스파이'
                    when 'VOO' then '브이오오'
                    when 'SCHD' then '슈드'
                    when 'TQQQ' then '티큐큐큐'
                    when 'SQQQ' then '에스큐큐큐'
                    else name_ko
                end
                where (name_ko is null or trim(name_ko) = '')
                  and symbol in (
                      'AAPL', 'TSLA', 'NVDA', 'MSFT', 'GOOGL',
                      'GOOG', 'AMZN', 'META', 'NFLX', 'QQQ',
                      'SPY', 'VOO', 'SCHD', 'TQQQ', 'SQQQ'
                  )
                """);

        jdbcTemplate.execute("""
                update stocks
                set
                    ticker_normalized = lower(trim(ticker)),
                    name_ko_normalized = case
                        when name_ko is null then null
                        else lower(trim(name_ko))
                    end,
                    name_en_normalized = lower(trim(name_en)),
                    search_text = trim(
                        concat_ws(
                            ' ',
                            lower(trim(ticker)),
                            lower(trim(name_en)),
                            lower(trim(coalesce(name_ko, '')))
                        )
                    )
                """);

        jdbcTemplate.execute("""
                alter table stocks
                    alter column ticker_normalized set not null,
                    alter column name_en_normalized set not null,
                    alter column search_text set not null
                """);

        jdbcTemplate.execute("""
                update stocks s
                set finnhub_symbol = null
                from (
                    select
                        id,
                        row_number() over (
                            partition by finnhub_symbol
                            order by id asc
                        ) as row_number
                    from stocks
                    where finnhub_symbol is not null
                ) duplicated
                where s.id = duplicated.id
                  and duplicated.row_number > 1
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_stocks_finnhub_symbol
                    on stocks (finnhub_symbol)
                    where finnhub_symbol is not null
                """);

        jdbcTemplate.execute("""
                create index if not exists idx_stocks_ticker_normalized
                    on stocks (ticker_normalized)
                """);

        jdbcTemplate.execute("""
                create index if not exists idx_stocks_name_ko_normalized
                    on stocks (name_ko_normalized)
                """);

        jdbcTemplate.execute("""
                create index if not exists idx_stocks_name_en_normalized
                    on stocks (name_en_normalized)
                """);
    }
}
