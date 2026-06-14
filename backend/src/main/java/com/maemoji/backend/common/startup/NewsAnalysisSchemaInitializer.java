package com.maemoji.backend.common.startup;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class NewsAnalysisSchemaInitializer implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    public NewsAnalysisSchemaInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(ApplicationArguments args) {
        jdbcTemplate.execute("""
                alter table news_analysis_cache
                    add column if not exists news_id varchar(100),
                    add column if not exists symbol varchar(30),
                    add column if not exists keyword_score integer,
                    add column if not exists relevance_score integer,
                    add column if not exists impact_level varchar(20),
                    add column if not exists reason text,
                    add column if not exists recency_weight numeric(6, 4),
                    add column if not exists impact_weight numeric(6, 4),
                    add column if not exists weighted_score numeric(10, 4),
                    add column if not exists content_hash varchar(64),
                    add column if not exists analysis_batch_hash varchar(64),
                    add column if not exists analyzed_at timestamptz
                """);

        jdbcTemplate.execute("""
                update news_analysis_cache cache
                set
                    symbol = coalesce(cache.symbol, stocks.ticker),
                    keyword_score = coalesce(cache.keyword_score, 0),
                    relevance_score = coalesce(cache.relevance_score, 50),
                    impact_level = coalesce(cache.impact_level, 'MEDIUM'),
                    reason = coalesce(cache.reason, '기존 분석 데이터'),
                    recency_weight = coalesce(cache.recency_weight, 1.0),
                    impact_weight = coalesce(cache.impact_weight, 1.0),
                    weighted_score = coalesce(cache.weighted_score, cache.sentiment_score, 0),
                    content_hash = coalesce(
                        cache.content_hash,
                        md5(coalesce(cache.news_url, '') || '|' || cache.headline)
                    ),
                    analysis_batch_hash = coalesce(
                        cache.analysis_batch_hash,
                        md5(
                            coalesce(cache.symbol, stocks.ticker)
                            || '|'
                            || coalesce(cache.analyzed_at::text, cache.created_at::text)
                        )
                    ),
                    analyzed_at = coalesce(cache.analyzed_at, cache.created_at, now())
                from stocks
                where stocks.id = cache.stock_id
                """);

        jdbcTemplate.execute("""
                alter table news_analysis_cache
                    alter column symbol set not null,
                    alter column content_hash set not null,
                    alter column analysis_batch_hash set not null,
                    alter column analyzed_at set not null,
                    alter column analyzed_at set default now()
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_news_analysis_cache_stock_content
                    on news_analysis_cache (stock_id, content_hash)
                """);

        jdbcTemplate.execute("""
                create index if not exists idx_news_analysis_cache_symbol_analyzed_at
                    on news_analysis_cache (symbol, analyzed_at desc)
                """);

        addConstraintIfMissing(
                "ck_news_analysis_sentiment_score",
                "check (sentiment_score between -100 and 100)"
        );
        addConstraintIfMissing(
                "ck_news_analysis_keyword_score",
                "check (keyword_score between -100 and 100)"
        );
        addConstraintIfMissing(
                "ck_news_analysis_relevance_score",
                "check (relevance_score between 0 and 100)"
        );
        addConstraintIfMissing(
                "ck_news_analysis_impact_level",
                "check (impact_level in ('LOW', 'MEDIUM', 'HIGH'))"
        );
    }

    private void addConstraintIfMissing(String constraintName, String definition) {
        final Boolean exists = jdbcTemplate.queryForObject(
                "select exists (select 1 from pg_constraint where conname = ?)",
                Boolean.class,
                constraintName
        );
        if (!Boolean.TRUE.equals(exists)) {
            jdbcTemplate.execute(
                    "alter table news_analysis_cache add constraint "
                            + constraintName
                            + " "
                            + definition
            );
        }
    }
}
