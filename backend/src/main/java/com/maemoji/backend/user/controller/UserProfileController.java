package com.maemoji.backend.user.controller;

import com.maemoji.backend.auth.dto.AuthUserResponse;
import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.user.dto.NicknameAvailabilityResponse;
import com.maemoji.backend.user.dto.NicknameUpdateRequest;
import com.maemoji.backend.user.dto.RiskProfileSurveyRequest;
import com.maemoji.backend.user.dto.RiskProfileSurveyResponse;
import com.maemoji.backend.user.service.RiskProfileService;
import com.maemoji.backend.user.service.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users/me")
public class UserProfileController {

    private final AuthenticatedUserResolver authenticatedUserResolver;
    private final RiskProfileService riskProfileService;
    private final UserProfileService userProfileService;

    public UserProfileController(
            AuthenticatedUserResolver authenticatedUserResolver,
            RiskProfileService riskProfileService,
            UserProfileService userProfileService
    ) {
        this.authenticatedUserResolver = authenticatedUserResolver;
        this.riskProfileService = riskProfileService;
        this.userProfileService = userProfileService;
    }

    @GetMapping("/nickname-availability")
    public ApiResponse<NicknameAvailabilityResponse> checkNicknameAvailability(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @RequestParam("nickname") String nickname
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(userProfileService.checkNicknameAvailability(userId, nickname));
    }

    @PutMapping("/nickname")
    public ApiResponse<AuthUserResponse> updateNickname(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody NicknameUpdateRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(userProfileService.updateNickname(userId, request.nickname()));
    }

    @PutMapping("/risk-profile")
    public ApiResponse<RiskProfileSurveyResponse> saveRiskProfile(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody RiskProfileSurveyRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(
                riskProfileService.saveOnboardingSurvey(userId, request.answers(), request.source())
        );
    }
}
