package com.maemoji.backend.portfolio.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.portfolio.dto.PortfolioCreateRequest;
import com.maemoji.backend.portfolio.dto.PortfolioItemSummaryResponse;
import com.maemoji.backend.portfolio.service.PortfolioService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/portfolio-items")
public class PortfolioController {

    private final PortfolioService portfolioService;

    public PortfolioController(PortfolioService portfolioService) {
        this.portfolioService = portfolioService;
    }

    @GetMapping
    public ApiResponse<List<PortfolioItemSummaryResponse>> getPortfolioItems() {
        return ApiResponse.ok(portfolioService.getPortfolioItems());
    }

    @PostMapping
    public ApiResponse<List<PortfolioItemSummaryResponse>> createPortfolioItem(
            @Valid @RequestBody PortfolioCreateRequest request
    ) {
        return ApiResponse.ok(portfolioService.createOrUpdatePortfolioItem(request));
    }

    @DeleteMapping("/{portfolioItemId}")
    public ApiResponse<List<PortfolioItemSummaryResponse>> deletePortfolioItem(
            @PathVariable("portfolioItemId") Long portfolioItemId
    ) {
        return ApiResponse.ok(portfolioService.deletePortfolioItem(portfolioItemId));
    }
}
