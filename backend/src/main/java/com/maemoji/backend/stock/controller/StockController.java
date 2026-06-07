package com.maemoji.backend.stock.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.stock.dto.StockQuoteResponse;
import com.maemoji.backend.stock.dto.StockSummaryResponse;
import com.maemoji.backend.stock.service.StockQuoteService;
import com.maemoji.backend.stock.service.StockService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequestMapping("/api/stocks")
public class StockController {

    private final StockService stockService;
    private final StockQuoteService stockQuoteService;

    public StockController(
            StockService stockService,
            StockQuoteService stockQuoteService
    ) {
        this.stockService = stockService;
        this.stockQuoteService = stockQuoteService;
    }

    @GetMapping("/search")
    public ApiResponse<List<StockSummaryResponse>> searchStocks(
            @RequestParam(name = "keyword", defaultValue = "") String keyword
    ) {
        return ApiResponse.ok(stockService.searchStocks(keyword));
    }

    @GetMapping("/{stockId}/quote")
    public ApiResponse<StockQuoteResponse> fetchStockQuote(
            @PathVariable("stockId") Long stockId
    ) {
        return ApiResponse.ok(stockQuoteService.fetchQuote(stockId));
    }
}
