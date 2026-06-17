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

        jdbcTemplate.execute("""
                delete from recommendation_factor_details details
                using (
                    select id
                    from (
                        select
                            id,
                            row_number() over (
                                partition by recommendation_id, factor_code
                                order by id desc
                            ) as row_number
                        from recommendation_factor_details
                    ) ranked
                    where ranked.row_number > 1
                ) duplicated
                where details.id = duplicated.id
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_recommendation_factor_details_recommendation_factor
                    on recommendation_factor_details (recommendation_id, factor_code)
                """);
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
