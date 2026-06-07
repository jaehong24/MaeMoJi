package com.maemoji.backend.stock.controller;

import com.maemoji.backend.batch.security.BatchAdminAuthorizer;
import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.stock.dto.TopStockSyncResult;
import com.maemoji.backend.stock.service.TopStockSyncService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/batches/top-stocks")
public class StockBatchAdminController {

    private final TopStockSyncService topStockSyncService;
    private final BatchAdminAuthorizer authorizer;

    public StockBatchAdminController(
            TopStockSyncService topStockSyncService,
            BatchAdminAuthorizer authorizer
    ) {
        this.topStockSyncService = topStockSyncService;
        this.authorizer = authorizer;
    }

    /// 스케줄을 기다리지 않고 관리자 수동 호출로 즉시 동기화할 수 있습니다.
    @PostMapping("/sync")
    public ApiResponse<TopStockSyncResult> syncTopStocks(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(topStockSyncService.refreshExistingStocks(false, limit));
    }

    /// 초기 종목 마스터를 외부 API에서 수집해 상위 종목으로 채웁니다.
    @PostMapping("/bootstrap")
    public ApiResponse<TopStockSyncResult> bootstrapTopStocks(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(topStockSyncService.importTopStocksFromApi(limit));
    }
}
