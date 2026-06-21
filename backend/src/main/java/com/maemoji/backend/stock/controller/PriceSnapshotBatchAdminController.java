package com.maemoji.backend.stock.controller;

import com.maemoji.backend.batch.security.BatchAdminAuthorizer;
import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.stock.dto.PriceHistoryBackfillResult;
import com.maemoji.backend.stock.dto.PriceSnapshotBatchResult;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/batches/price-snapshots")
public class PriceSnapshotBatchAdminController {

    private final StockPriceSnapshotBatchService stockPriceSnapshotBatchService;
    private final BatchAdminAuthorizer authorizer;

    public PriceSnapshotBatchAdminController(
            StockPriceSnapshotBatchService stockPriceSnapshotBatchService,
            BatchAdminAuthorizer authorizer
    ) {
        this.stockPriceSnapshotBatchService = stockPriceSnapshotBatchService;
        this.authorizer = authorizer;
    }

    @PostMapping("/sync")
    public ApiResponse<PriceSnapshotBatchResult> syncPriceSnapshots(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(stockPriceSnapshotBatchService.syncSnapshots(limit, false));
    }

    @PostMapping("/history-backfill")
    public ApiResponse<PriceHistoryBackfillResult> backfillPriceHistory(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret,
            @RequestParam(name = "limit", required = false) Integer limit,
            @RequestParam(name = "days", required = false) Integer days
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(stockPriceSnapshotBatchService.backfillHistoricalSnapshots(limit, days));
    }

    @PostMapping("/history-backfill-by-stock-ids")
    public ApiResponse<Integer> backfillPriceHistoryByStockIds(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret,
            @RequestParam(name = "stockIds") List<Long> stockIds,
            @RequestParam(name = "days", required = false) Integer days
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(stockPriceSnapshotBatchService.backfillHistoricalSnapshotsForStockIds(stockIds, days));
    }
}
