package com.maemoji.backend.batch.security;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class BatchExecutionLock {
    private static final long DAILY_BATCH_LOCK_KEY = 8_401_960_519L;
    private final JdbcTemplate jdbcTemplate;

    public BatchExecutionLock(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public boolean tryAcquireDaily() {
        Boolean acquired = jdbcTemplate.queryForObject(
                "select pg_try_advisory_lock(?)", Boolean.class, DAILY_BATCH_LOCK_KEY
        );
        return Boolean.TRUE.equals(acquired);
    }

    public void releaseDaily() {
        jdbcTemplate.queryForObject(
                "select pg_advisory_unlock(?)", Boolean.class, DAILY_BATCH_LOCK_KEY
        );
    }
}
