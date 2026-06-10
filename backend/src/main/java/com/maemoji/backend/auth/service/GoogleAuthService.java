package com.maemoji.backend.auth.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.auth.dto.AuthLoginResponse;
import com.maemoji.backend.auth.dto.AuthUserResponse;
import com.maemoji.backend.user.domain.UserSessionRecord;
import com.maemoji.backend.user.mapper.UserMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class GoogleAuthService {

    private static final Duration SESSION_TTL = Duration.ofDays(30);
    private static final String DEFAULT_WEB_CLIENT_ID =
            "868949164440-fph4vc0lnrdi3src47alvid1qg1vp930.apps.googleusercontent.com";

    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public GoogleAuthService(UserMapper userMapper, ObjectMapper objectMapper) {
        this.userMapper = userMapper;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Transactional
    public AuthLoginResponse login(String idToken) {
        final GoogleTokenProfile profile = verifyGoogleIdToken(idToken);
        final OffsetDateTime now = OffsetDateTime.now();

        UserSessionRecord existingByGoogleSubject =
                userMapper.findByGoogleSubject(profile.googleSubject());
        final Long userId;
        if (existingByGoogleSubject != null) {
            userId = existingByGoogleSubject.getId();
            userMapper.updateGoogleUserProfileById(
                    userId,
                    profile.email(),
                    profile.nickname(),
                    profile.profileImageUrl(),
                    profile.googleSubject(),
                    now
            );
        } else {
            userId = userMapper.upsertGoogleUserByEmail(
                    profile.email(),
                    profile.nickname(),
                    profile.profileImageUrl(),
                    profile.googleSubject(),
                    now
            );
        }

        final String accessToken = UUID.randomUUID().toString().replace("-", "")
                + UUID.randomUUID().toString().replace("-", "");
        final OffsetDateTime expiresAt = now.plus(SESSION_TTL);
        userMapper.updateAuthSession(userId, accessToken, expiresAt, now);

        final UserSessionRecord authenticatedUser = userMapper.findSessionUserByAuthToken(accessToken);
        if (authenticatedUser == null) {
            throw new IllegalStateException("로그인 사용자 세션을 생성하지 못했습니다.");
        }

        return new AuthLoginResponse(
                accessToken,
                expiresAt,
                new AuthUserResponse(
                        authenticatedUser.getId(),
                        authenticatedUser.getEmail(),
                        authenticatedUser.getNickname(),
                        authenticatedUser.getProfileImageUrl()
                )
        );
    }

    @Transactional
    public void logout(Long userId) {
        userMapper.clearAuthSession(userId);
    }

    private GoogleTokenProfile verifyGoogleIdToken(String idToken) {
        try {
            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(
                            "https://oauth2.googleapis.com/tokeninfo?id_token="
                                    + URLEncoder.encode(idToken, StandardCharsets.UTF_8)
                    ))
                    .timeout(Duration.ofSeconds(15))
                    .GET()
                    .build();

            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );
            if (response.statusCode() != 200 || response.body().isBlank()) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Google 토큰 검증에 실패했습니다.");
            }

            final JsonNode body = objectMapper.readTree(response.body());
            final String aud = body.path("aud").asText("");
            final String email = body.path("email").asText("");
            final String sub = body.path("sub").asText("");

            if (!resolveExpectedWebClientId().equals(aud)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Google 클라이언트 ID가 일치하지 않습니다.");
            }
            if (email.isBlank() || sub.isBlank()) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Google 사용자 정보가 올바르지 않습니다.");
            }

            final String nickname = body.path("name").asText(email.split("@")[0]);
            final String picture = body.path("picture").asText("");
            return new GoogleTokenProfile(sub, email, nickname, picture);
        } catch (ResponseStatusException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Google 토큰 검증 중 오류가 발생했습니다.");
        }
    }

    private String resolveExpectedWebClientId() {
        final String configured = System.getenv("GOOGLE_WEB_CLIENT_ID");
        if (configured == null || configured.isBlank()) {
            return DEFAULT_WEB_CLIENT_ID;
        }
        return configured.trim();
    }

    private record GoogleTokenProfile(
            String googleSubject,
            String email,
            String nickname,
            String profileImageUrl
    ) {
    }
}
