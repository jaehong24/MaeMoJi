package com.maemoji.backend.stock.controller;

import com.maemoji.backend.batch.security.BatchAdminAuthorizer;
import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.stock.dto.StockAssetTypeAuditRow;
import com.maemoji.backend.stock.dto.StockAssetTypeNormalizeResult;
import com.maemoji.backend.stock.dto.StockMasterSyncResult;
import com.maemoji.backend.stock.service.StockAssetTypeMaintenanceService;
import com.maemoji.backend.stock.service.StockSyncService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/stocks")
public class StockMasterAdminController {

    private final StockSyncService stockSyncService;
    private final StockAssetTypeMaintenanceService stockAssetTypeMaintenanceService;
    private final BatchAdminAuthorizer authorizer;

    public StockMasterAdminController(
            StockSyncService stockSyncService,
            StockAssetTypeMaintenanceService stockAssetTypeMaintenanceService,
            BatchAdminAuthorizer authorizer
    ) {
        this.stockSyncService = stockSyncService;
        this.stockAssetTypeMaintenanceService = stockAssetTypeMaintenanceService;
        this.authorizer = authorizer;
    }

    @PostMapping("/sync")
    public ApiResponse<StockMasterSyncResult> syncStocks(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(stockSyncService.syncAll());
    }

    @GetMapping("/asset-type/audit")
    public ApiResponse<List<StockAssetTypeAuditRow>> auditAssetTypes(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret,
            @RequestParam(name = "limit", defaultValue = "100") int limit
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(stockAssetTypeMaintenanceService.auditSuspiciousAssetTypes(limit));
    }

    @PostMapping("/asset-type/normalize")
    public ApiResponse<StockAssetTypeNormalizeResult> normalizeAssetTypes(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(stockAssetTypeMaintenanceService.normalizeAssetTypes());
    }
}
