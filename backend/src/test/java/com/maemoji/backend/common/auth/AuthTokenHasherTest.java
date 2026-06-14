package com.maemoji.backend.common.auth;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class AuthTokenHasherTest {

    private final AuthTokenHasher hasher = new AuthTokenHasher();

    @Test
    void createsStableSha256HashWithoutKeepingRawToken() {
        final String rawToken = "very-secret-session-token";

        final String first = hasher.hash(rawToken);
        final String second = hasher.hash(rawToken);

        assertThat(first).hasSize(64);
        assertThat(first).isEqualTo(second);
        assertThat(first).doesNotContain(rawToken);
    }
}
