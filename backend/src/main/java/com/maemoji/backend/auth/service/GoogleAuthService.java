package com.maemoji.backend.auth.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.auth.dto.AuthLoginResponse;
import com.maemoji.backend.auth.dto.AuthUserResponse;
import com.maemoji.backend.common.auth.AuthTokenHasher;
import com.maemoji.backend.user.domain.UserSessionRecord;
import com.maemoji.backend.user.mapper.UserMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.net.InetAddress;
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
    private static final String CURRENT_CONSENT_VERSION = "2026-06-14";
    private static final String DEFAULT_WEB_CLIENT_ID =
            "868949164440-fph4vc0lnrdi3src47alvid1qg1vp930.apps.googleusercontent.com";

    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;
    private final AuthTokenHasher authTokenHasher;

    public GoogleAuthService(
            UserMapper userMapper,
            ObjectMapper objectMapper,
            AuthTokenHasher authTokenHasher
    ) {
        this.userMapper = userMapper;
        this.objectMapper = objectMapper;
        this.authTokenHasher = authTokenHasher;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Transactional
    public AuthLoginResponse login(
            String idToken,
            boolean requiredConsentAccepted,
            String consentVersion
    ) {
        validateConsent(requiredConsentAccepted, consentVersion);
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
                    normalizeNicknameKey(profile.nickname()),
                    profile.profileImageUrl(),
                    profile.googleSubject(),
                    now
            );
        } else {
            userId = userMapper.upsertGoogleUserByEmail(
                    profile.email(),
                    profile.nickname(),
                    normalizeNicknameKey(profile.nickname()),
                    profile.profileImageUrl(),
                    profile.googleSubject(),
                    now
            );
        }

        userMapper.updateRequiredConsent(userId, consentVersion, now);
        final String accessToken = issueSessionToken(userId, now);

        final UserSessionRecord authenticatedUser = userMapper.findSessionUserByAuthToken(
                null,
                authTokenHasher.hash(accessToken)
        );
        if (authenticatedUser == null) {
            throw new IllegalStateException("로그인 사용자 세션을 생성하지 못했습니다.");
        }

        return new AuthLoginResponse(
                accessToken,
                now.plus(SESSION_TTL),
                new AuthUserResponse(
                        authenticatedUser.getId(),
                        authenticatedUser.getEmail(),
                        authenticatedUser.getNickname(),
                        authenticatedUser.getProfileImageUrl(),
                        Boolean.TRUE.equals(authenticatedUser.getNicknameConfirmed()),
                        authenticatedUser.getRiskProfile(),
                        authenticatedUser.getInvestmentDnaType(),
                        authenticatedUser.getRiskProfileScore(),
                        authenticatedUser.getRiskProfileConfidence(),
                        authenticatedUser.getRiskProfileSource()
                )
        );
    }

    @Transactional
    public AuthLoginResponse loginAsDev(String hostName) {
        if (!isAllowedDevHost(hostName)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "로컬 개발 환경에서만 사용할 수 있습니다.");
        }

        userMapper.insertDevUser();
        final Long userId = userMapper.findIdByEmail("dev@maemoji.local");
        if (userId == null) {
            throw new IllegalStateException("개발용 사용자 계정을 찾을 수 없습니다.");
        }

        final OffsetDateTime now = OffsetDateTime.now();
        final String accessToken = issueSessionToken(userId, now);
        final UserSessionRecord authenticatedUser = userMapper.findSessionUserByAuthToken(
                null,
                authTokenHasher.hash(accessToken)
        );
        if (authenticatedUser == null) {
            throw new IllegalStateException("개발용 로그인 세션을 생성하지 못했습니다.");
        }

        return new AuthLoginResponse(
                accessToken,
                now.plus(SESSION_TTL),
                new AuthUserResponse(
                        authenticatedUser.getId(),
                        authenticatedUser.getEmail(),
                        authenticatedUser.getNickname(),
                        authenticatedUser.getProfileImageUrl(),
                        Boolean.TRUE.equals(authenticatedUser.getNicknameConfirmed()),
                        authenticatedUser.getRiskProfile(),
                        authenticatedUser.getInvestmentDnaType(),
                        authenticatedUser.getRiskProfileScore(),
                        authenticatedUser.getRiskProfileConfidence(),
                        authenticatedUser.getRiskProfileSource()
                )
        );
    }

    @Transactional
    public void logout(Long userId) {
        userMapper.clearAuthSession(userId);
    }

    private String issueSessionToken(Long userId, OffsetDateTime now) {
        final String accessToken = UUID.randomUUID().toString().replace("-", "")
                + UUID.randomUUID().toString().replace("-", "");
        final OffsetDateTime expiresAt = now.plus(SESSION_TTL);
        userMapper.updateAuthSession(
                userId,
                authTokenHasher.hash(accessToken),
                expiresAt,
                now
        );
        return accessToken;
    }

    private void validateConsent(boolean requiredConsentAccepted, String consentVersion) {
        if (!requiredConsentAccepted) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "필수 안내 동의가 필요합니다.");
        }
        if (!CURRENT_CONSENT_VERSION.equals(consentVersion)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "최신 서비스 안내에 다시 동의해주세요.");
        }
    }

    private boolean isAllowedDevHost(String hostName) {
        if (hostName == null || hostName.isBlank()) {
            return false;
        }

        final String normalized = hostName.trim().toLowerCase();
        if (normalized.equals("localhost")
                || normalized.equals("127.0.0.1")
                || normalized.equals("10.0.2.2")) {
            return true;
        }

        try {
            final InetAddress address = InetAddress.getByName(normalized);
            return address.isLoopbackAddress() || address.isAnyLocalAddress();
        } catch (Exception ignored) {
            return false;
        }
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
            final boolean emailVerified = body.path("email_verified").asBoolean(false);

            if (!resolveExpectedWebClientId().equals(aud)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Google 클라이언트 ID가 일치하지 않습니다.");
            }
            if (email.isBlank() || sub.isBlank() || !emailVerified) {
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

    private String normalizeNicknameKey(String nickname) {
        return nickname == null ? "" : nickname.trim().toLowerCase();
    }

    private record GoogleTokenProfile(
            String googleSubject,
            String email,
            String nickname,
            String profileImageUrl
    ) {
    }
}
