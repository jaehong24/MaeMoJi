package com.maemoji.backend.portfolio.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.common.security.ApiRateLimiter;
import com.maemoji.backend.portfolio.dto.PortfolioCreateRequest;
import com.maemoji.backend.portfolio.dto.PortfolioItemSummaryResponse;
import com.maemoji.backend.portfolio.service.PortfolioService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.time.Duration;

@RestController
@RequestMapping("/api/portfolio-items")
public class PortfolioController {

    private final PortfolioService portfolioService;
    private final AuthenticatedUserResolver authenticatedUserResolver;
    private final ApiRateLimiter apiRateLimiter;

    public PortfolioController(
            PortfolioService portfolioService,
            AuthenticatedUserResolver authenticatedUserResolver,
            ApiRateLimiter apiRateLimiter
    ) {
        this.portfolioService = portfolioService;
        this.authenticatedUserResolver = authenticatedUserResolver;
        this.apiRateLimiter = apiRateLimiter;
    }

    @GetMapping
    public ApiResponse<List<PortfolioItemSummaryResponse>> getPortfolioItems(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(portfolioService.getPortfolioItems(userId));
    }

    @PostMapping
    public ApiResponse<List<PortfolioItemSummaryResponse>> createPortfolioItem(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody PortfolioCreateRequest request
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        apiRateLimiter.checkUser(userId, "portfolio-save", 10, Duration.ofHours(1));
        return ApiResponse.ok(portfolioService.createOrUpdatePortfolioItem(userId, request));
    }

    @DeleteMapping("/{portfolioItemId}")
    public ApiResponse<List<PortfolioItemSummaryResponse>> deletePortfolioItem(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable("portfolioItemId") Long portfolioItemId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(portfolioService.deletePortfolioItem(userId, portfolioItemId));
    }
}
