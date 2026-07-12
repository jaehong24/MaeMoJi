package com.maemoji.backend.portfolioinsight.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.portfolioinsight.dto.PortfolioReasonOptionResponse;
import com.maemoji.backend.portfolioinsight.dto.PortfolioReasonResponse;
import com.maemoji.backend.portfolioinsight.dto.PortfolioReasonUpdateRequest;
import com.maemoji.backend.portfolioinsight.service.PortfolioInsightService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/portfolio-items")
public class PortfolioInsightController {

    private final PortfolioInsightService portfolioInsightService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public PortfolioInsightController(
            PortfolioInsightService portfolioInsightService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.portfolioInsightService = portfolioInsightService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @GetMapping("/reason-options")
    public ApiResponse<List<PortfolioReasonOptionResponse>> getReasonOptions() {
        return ApiResponse.ok(portfolioInsightService.getReasonOptions());
    }

    @GetMapping("/{portfolioItemId}/reasons")
    public ApiResponse<List<PortfolioReasonResponse>> getPortfolioReasons(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable Long portfolioItemId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(portfolioInsightService.getPortfolioReasons(userId, portfolioItemId));
    }

    @PutMapping("/{portfolioItemId}/reasons")
    public ApiResponse<List<PortfolioReasonResponse>> updatePortfolioReasons(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable Long portfolioItemId,
            @Valid @RequestBody PortfolioReasonUpdateRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(portfolioInsightService.updatePortfolioReasons(userId, portfolioItemId, request));
    }
}
