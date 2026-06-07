package com.maemoji.backend.stock.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.stock.dto.TopStockSyncResult;
import com.maemoji.backend.stock.service.TopStockSyncService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/batches/top-stocks")
public class StockBatchAdminController {

    private final TopStockSyncService topStockSyncService;

    public StockBatchAdminController(TopStockSyncService topStockSyncService) {
        this.topStockSyncService = topStockSyncService;
    }

    /// 스케줄을 기다리지 않고 관리자 수동 호출로 즉시 동기화할 수 있습니다.
    @PostMapping("/sync")
    public ApiResponse<TopStockSyncResult> syncTopStocks(
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.ok(topStockSyncService.refreshExistingStocks(false, limit));
    }

    /// 초기 종목 마스터를 외부 API에서 수집해 상위 종목으로 채웁니다.
    @PostMapping("/bootstrap")
    public ApiResponse<TopStockSyncResult> bootstrapTopStocks(
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.ok(topStockSyncService.importTopStocksFromApi(limit));
    }
}
