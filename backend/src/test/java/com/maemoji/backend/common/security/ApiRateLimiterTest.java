package com.maemoji.backend.common.security;

import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;
import java.time.Duration;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ApiRateLimiterTest {
    @Test
    void blocksAfterOperationLimit() {
        final ApiRateLimiter limiter = new ApiRateLimiter();
        limiter.checkUser(7L, "test", 2, Duration.ofHours(1));
        limiter.checkUser(7L, "test", 2, Duration.ofHours(1));
        assertThatThrownBy(() -> limiter.checkUser(7L, "test", 2, Duration.ofHours(1)))
                .isInstanceOfSatisfying(ResponseStatusException.class,
                        error -> org.assertj.core.api.Assertions.assertThat(error.getStatusCode().value()).isEqualTo(429));
    }

    @Test
    void separatesUsersAndOperations() {
        final ApiRateLimiter limiter = new ApiRateLimiter();
        limiter.checkUser(7L, "test", 1, Duration.ofHours(1));
        limiter.checkUser(8L, "test", 1, Duration.ofHours(1));
        limiter.checkUser(7L, "other", 1, Duration.ofHours(1));
    }
}
