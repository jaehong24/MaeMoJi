package com.maemoji.backend.market.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.market.dto.ExchangeRateResponse;
import com.maemoji.backend.market.service.ExchangeRateService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/market")
public class MarketController {

    private final ExchangeRateService exchangeRateService;

    public MarketController(ExchangeRateService exchangeRateService) {
        this.exchangeRateService = exchangeRateService;
    }

    @GetMapping("/exchange-rates/usd-krw")
    public ApiResponse<ExchangeRateResponse> fetchUsdKrwRate() {
        return ApiResponse.ok(exchangeRateService.fetchUsdKrwRate());
    }
}
