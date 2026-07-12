package com.maemoji.backend.portfolioinsight.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.portfolioinsight.dto.UserDeviceTokenDeactivateRequest;
import com.maemoji.backend.portfolioinsight.dto.UserDeviceTokenResponse;
import com.maemoji.backend.portfolioinsight.dto.UserDeviceTokenUpsertRequest;
import com.maemoji.backend.portfolioinsight.dto.UserNotificationPreferenceResponse;
import com.maemoji.backend.portfolioinsight.dto.UserNotificationPreferenceUpdateRequest;
import com.maemoji.backend.portfolioinsight.dto.TestPushNotificationRequest;
import com.maemoji.backend.portfolioinsight.dto.TestPushNotificationResponse;
import com.maemoji.backend.portfolioinsight.service.PushNotificationDispatchService;
import com.maemoji.backend.portfolioinsight.service.PushNotificationSettingsService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class PushNotificationController {

    private final PushNotificationSettingsService pushNotificationSettingsService;
    private final PushNotificationDispatchService pushNotificationDispatchService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public PushNotificationController(
            PushNotificationSettingsService pushNotificationSettingsService,
            PushNotificationDispatchService pushNotificationDispatchService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.pushNotificationSettingsService = pushNotificationSettingsService;
        this.pushNotificationDispatchService = pushNotificationDispatchService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @GetMapping("/preferences")
    public ApiResponse<UserNotificationPreferenceResponse> getPreferences(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(pushNotificationSettingsService.getPreferences(userId));
    }

    @PutMapping("/preferences")
    public ApiResponse<UserNotificationPreferenceResponse> updatePreferences(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody UserNotificationPreferenceUpdateRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(pushNotificationSettingsService.updatePreferences(userId, request));
    }

    @GetMapping("/devices")
    public ApiResponse<List<UserDeviceTokenResponse>> getDevices(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(pushNotificationSettingsService.getDevices(userId));
    }

    @PostMapping("/devices")
    public ApiResponse<UserDeviceTokenResponse> upsertDevice(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody UserDeviceTokenUpsertRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(pushNotificationSettingsService.upsertDevice(userId, request));
    }

    @DeleteMapping("/devices")
    public ApiResponse<Void> deactivateDevice(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody UserDeviceTokenDeactivateRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        pushNotificationSettingsService.deactivateDevice(userId, request);
        return ApiResponse.ok(null);
    }

    @PostMapping("/test")
    public ApiResponse<TestPushNotificationResponse> sendTestPush(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody(required = false) TestPushNotificationRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(pushNotificationDispatchService.sendTestPush(userId, request));
    }
}
