package com.maemoji.backend.stock.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.stock.dto.PriceSnapshotBatchResult;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/batches/price-snapshots")
public class PriceSnapshotBatchAdminController {

    private final StockPriceSnapshotBatchService stockPriceSnapshotBatchService;

    public PriceSnapshotBatchAdminController(
            StockPriceSnapshotBatchService stockPriceSnapshotBatchService
    ) {
        this.stockPriceSnapshotBatchService = stockPriceSnapshotBatchService;
    }

    @PostMapping("/sync")
    public ApiResponse<PriceSnapshotBatchResult> syncPriceSnapshots(
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.ok(stockPriceSnapshotBatchService.syncSnapshots(limit, false));
    }
}
