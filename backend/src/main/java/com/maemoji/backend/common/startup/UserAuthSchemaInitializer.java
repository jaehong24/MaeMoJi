package com.maemoji.backend.common.startup;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class UserAuthSchemaInitializer implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    public UserAuthSchemaInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(ApplicationArguments args) {
        jdbcTemplate.execute("""
                alter table users
                    add column if not exists google_subject varchar(255),
                    add column if not exists profile_image_url text,
                    add column if not exists nickname_normalized text,
                    add column if not exists nickname_confirmed boolean,
                    add column if not exists risk_profile varchar(30),
                    add column if not exists investment_dna_type varchar(40),
                    add column if not exists risk_profile_score integer,
                    add column if not exists risk_profile_confidence integer,
                    add column if not exists risk_profile_source varchar(30),
                    add column if not exists risk_profile_updated_at timestamptz,
                    add column if not exists auth_token varchar(255),
                    add column if not exists auth_token_hash varchar(64),
                    add column if not exists auth_token_expires_at timestamptz,
                    add column if not exists last_login_at timestamptz,
                    add column if not exists required_consent_version varchar(30),
                    add column if not exists required_consent_agreed_at timestamptz
                """);

        jdbcTemplate.execute("""
                update users
                set
                    nickname_normalized = case
                        when nickname is null or trim(nickname) = '' then null
                        else lower(trim(nickname))
                    end,
                    nickname_confirmed = coalesce(
                        nickname_confirmed,
                        case
                            when nickname is null or trim(nickname) = '' then false
                            else true
                        end
                    )
                where nickname_normalized is null
                   or nickname_confirmed is null
                """);

        jdbcTemplate.execute("""
                alter table users
                    drop constraint if exists ck_users_risk_profile,
                    add constraint ck_users_risk_profile
                        check (
                            risk_profile is null
                            or risk_profile in ('CONSERVATIVE', 'BALANCED', 'AGGRESSIVE')
                        ),
                    drop constraint if exists ck_users_risk_profile_confidence,
                    add constraint ck_users_risk_profile_confidence
                        check (
                            risk_profile_confidence is null
                            or risk_profile_confidence between 0 and 100
                        ),
                    drop constraint if exists ck_users_risk_profile_score,
                    add constraint ck_users_risk_profile_score
                        check (
                            risk_profile_score is null
                            or risk_profile_score between 12 and 60
                        ),
                    drop constraint if exists ck_users_investment_dna_type,
                    add constraint ck_users_investment_dna_type
                        check (
                            investment_dna_type is null
                            or investment_dna_type in (
                                'SAFE_FIRST',
                                'BALANCE_SEEKER',
                                'GROWTH_SEEKER',
                                'AGGRESSIVE_INVESTOR',
                                'WEALTH_MASTER'
                            )
                        ),
                    drop constraint if exists ck_users_risk_profile_source,
                    add constraint ck_users_risk_profile_source
                        check (
                            risk_profile_source is null
                            or risk_profile_source in ('ONBOARDING_SURVEY', 'MANUAL_UPDATE', 'SYSTEM_DEFAULT')
                        )
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_users_google_subject
                    on users (google_subject)
                """);

        jdbcTemplate.execute("""
                create index if not exists idx_users_nickname_normalized
                    on users (nickname_normalized)
                """);

        jdbcTemplate.execute("""
                with duplicate_nicknames as (
                    select
                        id,
                        row_number() over (
                            partition by nickname_normalized
                            order by id
                        ) as duplicate_order
                    from users
                    where nickname_confirmed = true
                      and nickname_normalized is not null
                )
                update users
                set
                    nickname_confirmed = false,
                    nickname_normalized = null,
                    updated_at = now()
                where id in (
                    select id
                    from duplicate_nicknames
                    where duplicate_order > 1
                )
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_users_confirmed_nickname
                    on users (nickname_normalized)
                    where nickname_confirmed = true
                      and nickname_normalized is not null
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_users_auth_token
                    on users (auth_token)
                    where auth_token is not null
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_users_auth_token_hash
                    on users (auth_token_hash)
                    where auth_token_hash is not null
                """);
    }
}
