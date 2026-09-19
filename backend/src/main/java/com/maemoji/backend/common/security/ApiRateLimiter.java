package com.maemoji.backend.common.security;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/** Small per-instance guard for expensive authenticated operations. */
@Component
public class ApiRateLimiter {
    private final Map<String, Window> windows = new HashMap<>();

    public synchronized void checkUser(Long userId, String operation, int maxRequests, Duration window) {
        final String key = operation + ":" + userId;
        final Instant now = Instant.now();
        final Window current = windows.get(key);
        if (current == null || now.isAfter(current.startedAt().plus(window))) {
            windows.put(key, new Window(now, 1));
            evictExpired(now, window);
            return;
        }
        if (current.count() >= maxRequests) {
            throw new ResponseStatusException(
                    HttpStatus.TOO_MANY_REQUESTS,
                    "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
            );
        }
        windows.put(key, new Window(current.startedAt(), current.count() + 1));
    }

    private void evictExpired(Instant now, Duration window) {
        windows.entrySet().removeIf(entry -> now.isAfter(entry.getValue().startedAt().plus(window)));
    }

    private record Window(Instant startedAt, int count) { }
}
