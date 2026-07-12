package com.maemoji.backend.portfolioinsight.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.portfolioinsight.dto.UserAlertEventResponse;
import com.maemoji.backend.portfolioinsight.service.UserAlertEventService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/alerts")
public class UserAlertEventController {

    private final UserAlertEventService userAlertEventService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public UserAlertEventController(
            UserAlertEventService userAlertEventService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.userAlertEventService = userAlertEventService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @GetMapping
    public ApiResponse<List<UserAlertEventResponse>> getAlerts(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(userAlertEventService.getAlerts(userId));
    }

    @PostMapping("/{alertId}/read")
    public ApiResponse<UserAlertEventResponse> markAsRead(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable Long alertId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(userAlertEventService.markAsRead(userId, alertId));
    }
}
