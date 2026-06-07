package com.maemoji.backend.recommendation.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.recommendation.dto.HomeRecommendationResponse;
import com.maemoji.backend.recommendation.dto.NewsEngineStatusResponse;
import com.maemoji.backend.recommendation.dto.RecommendationResponse;
import com.maemoji.backend.recommendation.service.NewsSentimentService;
import com.maemoji.backend.recommendation.service.RecommendationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {

    private final RecommendationService recommendationService;
    private final NewsSentimentService newsSentimentService;

    public RecommendationController(
            RecommendationService recommendationService,
            NewsSentimentService newsSentimentService
    ) {
        this.recommendationService = recommendationService;
        this.newsSentimentService = newsSentimentService;
    }

    @GetMapping
    public ApiResponse<List<RecommendationResponse>> getLatestRecommendations() {
        return ApiResponse.ok(recommendationService.getLatestRecommendations());
    }

    @GetMapping("/{portfolioItemId:\\d+}")
    public ApiResponse<RecommendationResponse> getRecommendationDetail(
            @PathVariable Long portfolioItemId
    ) {
        return ApiResponse.ok(recommendationService.getRecommendationDetail(portfolioItemId));
    }

    @GetMapping("/home")
    public ApiResponse<HomeRecommendationResponse> getHomeRecommendations() {
        return ApiResponse.ok(recommendationService.getLightweightHomeRecommendations());
    }

    @PostMapping("/generate")
    public ApiResponse<List<RecommendationResponse>> generateRecommendations() {
        return ApiResponse.ok(recommendationService.generateLatestRecommendations());
    }

    @GetMapping("/news-engine/status")
    public ApiResponse<NewsEngineStatusResponse> getNewsEngineStatus() {
        return ApiResponse.ok(newsSentimentService.getStatus());
    }
}
