package com.maemoji.backend.batch.security;

import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class BatchExecutionLockTest {
    @Test
    void usesPostgresSessionAdvisoryLock() {
        final JdbcTemplate jdbc = mock(JdbcTemplate.class);
        final BatchExecutionLock lock = new BatchExecutionLock(jdbc);
        when(jdbc.queryForObject(anyString(), eq(Boolean.class), any(Long.class))).thenReturn(true, true);
        assertThat(lock.tryAcquireDaily()).isTrue();
        lock.releaseDaily();
        verify(jdbc, times(2)).queryForObject(anyString(), eq(Boolean.class), any(Long.class));
    }

    @Test
    void reportsWhenAnotherInstanceOwnsLock() {
        final JdbcTemplate jdbc = mock(JdbcTemplate.class);
        when(jdbc.queryForObject(anyString(), eq(Boolean.class), any(Long.class))).thenReturn(false);
        assertThat(new BatchExecutionLock(jdbc).tryAcquireDaily()).isFalse();
    }
}
