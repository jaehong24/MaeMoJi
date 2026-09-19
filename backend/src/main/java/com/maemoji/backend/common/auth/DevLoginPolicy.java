package com.maemoji.backend.common.auth;

import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.util.Locale;
import java.util.Set;

@Component
public class DevLoginPolicy {
    private static final Set<String> LOCAL_HOSTS = Set.of(
            "localhost", "127.0.0.1", "::1", "[::1]", "10.0.2.2"
    );
    private static final Set<String> LOOPBACK_PEERS = Set.of(
            "127.0.0.1", "::1", "0:0:0:0:0:0:0:1"
    );
    private final Environment environment;

    public DevLoginPolicy(Environment environment) {
        this.environment = environment;
    }

    public void requireLocalDevelopment(String serverName, String remoteAddress) {
        // Host and forwarding headers are client input, never a production auth boundary.
        if (environment.acceptsProfiles(Profiles.of("prod", "production"))
                || !environment.acceptsProfiles(Profiles.of("local", "dev"))
                || !environment.getProperty("maemoji.auth.dev-login-enabled", Boolean.class, false)
                || !LOCAL_HOSTS.contains(normalize(serverName))
                || !LOOPBACK_PEERS.contains(normalize(remoteAddress))) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "로컬 개발 환경에서만 사용할 수 있습니다.");
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
    }
}
