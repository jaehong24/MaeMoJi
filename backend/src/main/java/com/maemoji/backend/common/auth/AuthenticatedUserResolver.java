package com.maemoji.backend.common.auth;

import com.maemoji.backend.user.domain.UserSessionRecord;
import com.maemoji.backend.user.mapper.UserMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
public class AuthenticatedUserResolver {

    private final UserMapper userMapper;

    public AuthenticatedUserResolver(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public Long requireUserId(String authorizationHeader) {
        return requireUser(authorizationHeader).getId();
    }

    public UserSessionRecord requireUser(String authorizationHeader) {
        final String token = extractBearerToken(authorizationHeader);
        final UserSessionRecord user = userMapper.findSessionUserByAuthToken(token);
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        return user;
    }

    private String extractBearerToken(String authorizationHeader) {
        if (authorizationHeader == null || authorizationHeader.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증 토큰이 없습니다.");
        }
        if (!authorizationHeader.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증 형식이 올바르지 않습니다.");
        }

        final String token = authorizationHeader.substring("Bearer ".length()).trim();
        if (token.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증 토큰이 비어 있습니다.");
        }
        return token;
    }
}
