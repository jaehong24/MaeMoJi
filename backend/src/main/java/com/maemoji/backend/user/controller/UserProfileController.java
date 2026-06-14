package com.maemoji.backend.user.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.user.dto.RiskProfileSurveyRequest;
import com.maemoji.backend.user.dto.RiskProfileSurveyResponse;
import com.maemoji.backend.user.service.RiskProfileService;
import jakarta.validation.Valid;
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

    public UserProfileController(
            AuthenticatedUserResolver authenticatedUserResolver,
            RiskProfileService riskProfileService
    ) {
        this.authenticatedUserResolver = authenticatedUserResolver;
        this.riskProfileService = riskProfileService;
    }

    @PutMapping("/risk-profile")
    public ApiResponse<RiskProfileSurveyResponse> saveRiskProfile(
            @RequestHeader("Authorization") String authorizationHeader,
            @Valid @RequestBody RiskProfileSurveyRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(
                riskProfileService.saveOnboardingSurvey(userId, request.answers(), request.source())
        );
    }
}
