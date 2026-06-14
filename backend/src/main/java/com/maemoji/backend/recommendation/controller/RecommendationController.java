package com.maemoji.backend.recommendation.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.recommendation.dto.HomeRecommendationResponse;
import com.maemoji.backend.recommendation.dto.NewsEngineStatusResponse;
import com.maemoji.backend.recommendation.dto.RecommendationResponse;
import com.maemoji.backend.recommendation.service.NewsSentimentService;
import com.maemoji.backend.recommendation.service.RecommendationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {

    private final RecommendationService recommendationService;
    private final NewsSentimentService newsSentimentService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public RecommendationController(
            RecommendationService recommendationService,
            NewsSentimentService newsSentimentService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.recommendationService = recommendationService;
        this.newsSentimentService = newsSentimentService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @GetMapping
    public ApiResponse<List<RecommendationResponse>> getLatestRecommendations(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(recommendationService.getLatestRecommendations(userId));
    }

    @GetMapping("/{portfolioItemId:\\d+}")
    public ApiResponse<RecommendationResponse> getRecommendationDetail(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable("portfolioItemId") Long portfolioItemId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(recommendationService.getOptimizedRecommendationDetail(userId, portfolioItemId));
    }

    @PostMapping("/{portfolioItemId:\\d+}/refresh")
    public ApiResponse<RecommendationResponse> refreshRecommendationDetail(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable("portfolioItemId") Long portfolioItemId
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(recommendationService.refreshRecommendationDetail(userId, portfolioItemId));
    }

    @GetMapping("/home")
    public ApiResponse<HomeRecommendationResponse> getHomeRecommendations(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(recommendationService.getOptimizedHomeRecommendations(userId));
    }

    @PostMapping("/generate")
    public ApiResponse<List<RecommendationResponse>> generateRecommendations(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(recommendationService.generateLatestRecommendationsFromCachedData(userId));
    }

    @GetMapping("/news-engine/status")
    public ApiResponse<NewsEngineStatusResponse> getNewsEngineStatus(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(newsSentimentService.getStatus());
    }
}
