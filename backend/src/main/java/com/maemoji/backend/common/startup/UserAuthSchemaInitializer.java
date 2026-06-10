package com.maemoji.backend.common.startup;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
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
                    add column if not exists auth_token varchar(255),
                    add column if not exists auth_token_expires_at timestamptz,
                    add column if not exists last_login_at timestamptz
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_users_google_subject
                    on users (google_subject)
                """);

        jdbcTemplate.execute("""
                create unique index if not exists uk_users_auth_token
                    on users (auth_token)
                    where auth_token is not null
                """);
    }
}
