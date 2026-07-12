package com.maemoji.backend.toss.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.toss.dto.TossAccountResponse;
import com.maemoji.backend.toss.dto.TossAccountSelectionResponse;
import com.maemoji.backend.toss.dto.TossConnectionCreateRequest;
import com.maemoji.backend.toss.dto.TossConnectionCreateResponse;
import com.maemoji.backend.toss.dto.TossConnectionResponse;
import com.maemoji.backend.toss.dto.TossHoldingsPreviewResponse;
import com.maemoji.backend.toss.service.TossIntegrationService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/integrations/toss")
public class TossIntegrationController {

    private final TossIntegrationService tossIntegrationService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public TossIntegrationController(
            TossIntegrationService tossIntegrationService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.tossIntegrationService = tossIntegrationService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @PostMapping("/connections")
    public ApiResponse<TossConnectionCreateResponse> createConnection(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody TossConnectionCreateRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(tossIntegrationService.createConnection(userId, request));
    }

    @GetMapping("/connections/me")
    public ApiResponse<List<TossConnectionResponse>> getMyConnections(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(tossIntegrationService.getMyConnections(userId));
    }

    @GetMapping("/connections/{connectionId}/accounts")
    public ApiResponse<List<TossAccountResponse>> getAccounts(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable Long connectionId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(tossIntegrationService.getAccounts(userId, connectionId));
    }

    @PostMapping("/accounts/{accountId}/select")
    public ApiResponse<TossAccountSelectionResponse> selectAccount(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable Long accountId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(tossIntegrationService.selectAccount(userId, accountId));
    }

    @GetMapping("/accounts/{accountId}/holdings/preview")
    public ApiResponse<TossHoldingsPreviewResponse> previewHoldings(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable Long accountId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(tossIntegrationService.previewHoldings(userId, accountId));
    }
}
