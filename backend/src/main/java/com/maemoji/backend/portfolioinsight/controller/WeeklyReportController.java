package com.maemoji.backend.portfolioinsight.controller;

import com.maemoji.backend.common.api.ApiResponse;
import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.portfolioinsight.dto.WeeklyReportListItemResponse;
import com.maemoji.backend.portfolioinsight.dto.WeeklyReportResponse;
import com.maemoji.backend.portfolioinsight.service.WeeklyReportService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/reports/weekly")
public class WeeklyReportController {

    private final WeeklyReportService weeklyReportService;
    private final AuthenticatedUserResolver authenticatedUserResolver;

    public WeeklyReportController(
            WeeklyReportService weeklyReportService,
            AuthenticatedUserResolver authenticatedUserResolver
    ) {
        this.weeklyReportService = weeklyReportService;
        this.authenticatedUserResolver = authenticatedUserResolver;
    }

    @GetMapping("/latest")
    public ApiResponse<WeeklyReportResponse> getLatestWeeklyReport(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(weeklyReportService.getLatestReport(userId));
    }

    @GetMapping
    public ApiResponse<List<WeeklyReportListItemResponse>> getWeeklyReports(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(weeklyReportService.getWeeklyReports(userId));
    }

    @PostMapping("/refresh")
    public ApiResponse<WeeklyReportResponse> refreshWeeklyReport(
            @RequestHeader(name = "Authorization", required = false) String authorizationHeader
    ) {
        final Long userId = authenticatedUserResolver.requireUserId(authorizationHeader);
        return ApiResponse.ok(weeklyReportService.generateLatestReport(userId));
    }
}
