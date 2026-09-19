package com.maemoji.backend.common.auth;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.web.server.ResponseStatusException;

import static org.assertj.core.api.Assertions.*;

class DevLoginPolicyTest {
    private final MockEnvironment environment = new MockEnvironment();
    private final DevLoginPolicy policy = new DevLoginPolicy(environment);

    @ParameterizedTest
    @ValueSource(strings = {"prod", "production"})
    void productionCannotBeBypassedWithLocalHostOrEnabledFlag(String profile) {
        environment.setActiveProfiles(profile, "local");
        environment.setProperty("maemoji.auth.dev-login-enabled", "true");
        assertThatThrownBy(() -> policy.requireLocalDevelopment("localhost", "127.0.0.1"))
                .isInstanceOfSatisfying(ResponseStatusException.class,
                        error -> assertThat(error.getStatusCode().value()).isEqualTo(403));
    }

    @Test
    void disabledByDefaultEvenOnLoopback() {
        assertThatThrownBy(() -> policy.requireLocalDevelopment("localhost", "127.0.0.1"))
                .isInstanceOf(ResponseStatusException.class);
        environment.setActiveProfiles("local");
        assertThatThrownBy(() -> policy.requireLocalDevelopment("localhost", "127.0.0.1"))
                .isInstanceOf(ResponseStatusException.class);
    }

    @Test
    void explicitLocalOptInRequiresBothLocalHostAndPeer() {
        environment.setActiveProfiles("local");
        environment.setProperty("maemoji.auth.dev-login-enabled", "true");
        assertThatCode(() -> policy.requireLocalDevelopment("localhost", "127.0.0.1"))
                .doesNotThrowAnyException();
        assertThatThrownBy(() -> policy.requireLocalDevelopment("localhost", "203.0.113.1"))
                .isInstanceOf(ResponseStatusException.class);
        assertThatThrownBy(() -> policy.requireLocalDevelopment("example.com", "127.0.0.1"))
                .isInstanceOf(ResponseStatusException.class);
        assertThatThrownBy(() -> policy.requireLocalDevelopment(null, null))
                .isInstanceOf(ResponseStatusException.class);
    }
}
