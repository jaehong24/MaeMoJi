package com.maemoji.backend.auth.controller;

import com.maemoji.backend.auth.dto.AuthLoginResponse;
import com.maemoji.backend.auth.dto.AuthUserResponse;
import com.maemoji.backend.auth.dto.GoogleLoginRequest;
import com.maemoji.backend.auth.service.GoogleAuthService;
import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final GoogleAuthService googleAuthService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public AuthController(
            GoogleAuthService googleAuthService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.googleAuthService = googleAuthService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @PostMapping("/google")
    public ApiResponse<AuthLoginResponse> loginWithGoogle(
            @Valid @RequestBody GoogleLoginRequest request
    ) {
        return ApiResponse.ok(googleAuthService.login(request.idToken()));
    }

    @PostMapping("/dev")
    public ApiResponse<AuthLoginResponse> loginAsDev(HttpServletRequest request) {
        return ApiResponse.ok(googleAuthService.loginAsDev(request.getServerName()));
    }

    @GetMapping("/me")
    public ApiResponse<AuthUserResponse> getMe(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        final var user = authenticatedUserResolver.requireUser(authorizationHeader);
        return ApiResponse.ok(
                new AuthUserResponse(
                        user.getId(),
                        user.getEmail(),
                        user.getNickname(),
                        user.getProfileImageUrl()
                )
        );
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        googleAuthService.logout(userId);
        return ApiResponse.ok(null);
    }
}
