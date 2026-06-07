package com.maemoji.backend.batch.controller;

import com.maemoji.backend.batch.dto.DailyBatchResult;
import com.maemoji.backend.batch.security.BatchAdminAuthorizer;
import com.maemoji.backend.batch.service.DailyIntegratedBatchService;
import com.maemoji.backend.common.api.ApiResponse;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/batches/daily")
public class DailyBatchAdminController {

    private final DailyIntegratedBatchService dailyBatchService;
    private final BatchAdminAuthorizer authorizer;

    public DailyBatchAdminController(
            DailyIntegratedBatchService dailyBatchService,
            BatchAdminAuthorizer authorizer
    ) {
        this.dailyBatchService = dailyBatchService;
        this.authorizer = authorizer;
    }

    @PostMapping("/run")
    public ApiResponse<DailyBatchResult> run(
            @RequestHeader(name = "X-Batch-Secret", required = false) String batchSecret,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        authorizer.authorize(batchSecret);
        return ApiResponse.ok(dailyBatchService.run(limit));
    }
}
