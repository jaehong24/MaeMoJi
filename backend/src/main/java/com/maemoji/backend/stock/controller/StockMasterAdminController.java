package com.maemoji.backend.stock.controller;

import com.maemoji.backend.batch.security.BatchAdminAuthorizer;
import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.stock.dto.StockMasterSyncResult;
import com.maemoji.backend.stock.service.StockSyncService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/stocks")
public class StockMasterAdminController {

    private final StockSyncService stockSyncService;
    private final BatchAdminAuthorizer authorizer;

    public StockMasterAdminController(
            StockSyncService stockSyncService,
            BatchAdminAuthorizer authorizer
    ) {
        this.stockSyncService = stockSyncService;
        this.authorizer = authorizer;
    }

    @PostMapping("/sync")
    public ApiResponse<StockMasterSyncResult> syncStocks(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(stockSyncService.syncAll());
    }
}
