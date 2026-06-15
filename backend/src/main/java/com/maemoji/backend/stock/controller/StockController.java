package com.maemoji.backend.stock.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.stock.dto.StockQuoteResponse;
import com.maemoji.backend.stock.dto.StockSummaryResponse;
import com.maemoji.backend.stock.service.StockQuoteService;
import com.maemoji.backend.stock.service.StockService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequestMapping("/api/stocks")
public class StockController {

    private final StockService stockService;
    private final StockQuoteService stockQuoteService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public StockController(
            StockService stockService,
            StockQuoteService stockQuoteService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.stockService = stockService;
        this.stockQuoteService = stockQuoteService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @GetMapping("/search")
    public ApiResponse<List<StockSummaryResponse>> searchStocks(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @RequestParam(name = "query", required = false) String query,
            @RequestParam(name = "keyword", required = false) String keyword
    ) {
        authenticatedUserResolver.requireUserId(authorizationHeader);
        final String searchQuery = query == null ? keyword : query;
        return ApiResponse.ok(stockService.searchStocks(searchQuery));
    }

    @GetMapping("/{stockId}/quote")
    public ApiResponse<StockQuoteResponse> fetchStockQuote(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader,
            @PathVariable("stockId") Long stockId
    ) {
        authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(stockQuoteService.fetchQuote(stockId));
    }
}
