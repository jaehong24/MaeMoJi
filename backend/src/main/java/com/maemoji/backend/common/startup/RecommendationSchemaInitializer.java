package com.maemoji.backend.common.startup;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RecommendationSchemaInitializer implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    public RecommendationSchemaInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(ApplicationArguments args) {
        jdbcTemplate.execute("""
                alter table recommendations
                    add column if not exists formula_version varchar(50),
                    add column if not exists raw_score integer,
                    add column if not exists risk_adjustment integer,
                    add column if not exists price_score integer,
                    add column if not exists news_score integer,
                    add column if not exists price_weight integer,
                    add column if not exists news_weight integer,
                    add column if not exists price_return_30d numeric(10, 4),
                    add column if not exists news_sentiment_score integer,
                    add column if not exists increase_eligible boolean
                """);

        jdbcTemplate.execute("""
                update recommendations
                set
                    formula_version = coalesce(formula_version, engine_version, 'LEGACY'),
                    raw_score = coalesce(raw_score, engine_score),
                    risk_adjustment = coalesce(risk_adjustment, 0),
                    price_weight = coalesce(price_weight, 0),
                    news_weight = coalesce(news_weight, 0),
                    increase_eligible = coalesce(increase_eligible, false)
                """);

        addConstraintIfMissing(
                "ck_recommendations_raw_score",
                "check (raw_score between 0 and 100)"
        );
        addConstraintIfMissing(
                "ck_recommendations_price_score",
                "check (price_score between 0 and 100)"
        );
        addConstraintIfMissing(
                "ck_recommendations_news_score",
                "check (news_score between 0 and 100)"
        );
        addConstraintIfMissing(
                "ck_recommendations_price_weight",
                "check (price_weight between 0 and 100)"
        );
        addConstraintIfMissing(
                "ck_recommendations_news_weight",
                "check (news_weight between 0 and 100)"
        );
        addConstraintIfMissing(
                "ck_recommendations_news_sentiment_score",
                "check (news_sentiment_score between -100 and 100)"
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
                    "alter table recommendations add constraint "
                            + constraintName
                            + " "
                            + definition
            );
        }
    }
}
