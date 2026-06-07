package com.maemoji.backend.batch.security;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

@Component
public class BatchAdminAuthorizer {

    public void authorize(String providedSecret) {
        final String configuredSecret = System.getenv("BATCH_API_SECRET");
        if (configuredSecret == null || configuredSecret.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    "BATCH_API_SECRET 환경변수가 설정되지 않았습니다."
            );
        }

        final byte[] expected = configuredSecret.getBytes(StandardCharsets.UTF_8);
        final byte[] provided = providedSecret == null
                ? new byte[0]
                : providedSecret.getBytes(StandardCharsets.UTF_8);
        if (!MessageDigest.isEqual(expected, provided)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "배치 실행 권한이 없습니다.");
        }
    }
}
