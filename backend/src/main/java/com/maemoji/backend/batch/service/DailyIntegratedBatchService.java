package com.maemoji.backend.batch.service;

import com.maemoji.backend.batch.dto.DailyBatchResult;
import com.maemoji.backend.recommendation.dto.RecommendationResponse;
import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.portfolioinsight.service.WeeklyReportService;
import com.maemoji.backend.stock.dto.PriceSnapshotBatchResult;
import com.maemoji.backend.stock.dto.StockAssetTypeNormalizeResult;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import com.maemoji.backend.stock.service.StockAssetTypeMaintenanceService;
import com.maemoji.backend.user.mapper.UserMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

@Service
public class DailyIntegratedBatchService {

    private static final Logger log = LoggerFactory.getLogger(DailyIntegratedBatchService.class);
    private static final ZoneId BATCH_ZONE = ZoneId.of("Asia/Seoul");

    private final StockPriceSnapshotBatchService priceSnapshotBatchService;
    private final StockAssetTypeMaintenanceService stockAssetTypeMaintenanceService;
    private final RecommendationService recommendationService;
    private final WeeklyReportService weeklyReportService;
    private final UserMapper userMapper;
    private final AtomicBoolean running = new AtomicBoolean(false);

    public DailyIntegratedBatchService(
            StockPriceSnapshotBatchService priceSnapshotBatchService,
            StockAssetTypeMaintenanceService stockAssetTypeMaintenanceService,
            RecommendationService recommendationService,
            WeeklyReportService weeklyReportService,
            UserMapper userMapper
    ) {
        this.priceSnapshotBatchService = priceSnapshotBatchService;
        this.stockAssetTypeMaintenanceService = stockAssetTypeMaintenanceService;
        this.recommendationService = recommendationService;
        this.weeklyReportService = weeklyReportService;
        this.userMapper = userMapper;
    }

    public DailyBatchResult run(Integer priceLimit) {
        if (!running.compareAndSet(false, true)) {
            throw new IllegalStateException("일일 통합 배치가 이미 실행 중입니다.");
        }

        final OffsetDateTime startedAt = OffsetDateTime.now(BATCH_ZONE);
        PriceSnapshotBatchResult priceResult = null;

        try {
            log.info("일일 통합 배치를 시작합니다. startedAt={}, priceLimit={}", startedAt, priceLimit);
            final StockAssetTypeNormalizeResult assetTypeNormalizeResult =
                    stockAssetTypeMaintenanceService.normalizeAssetTypes();
            log.info(
                    "종목 asset_type 선보정을 완료했습니다. suspiciousBefore={}, updated={}, suspiciousAfter={}",
                    assetTypeNormalizeResult.suspiciousCountBefore(),
                    assetTypeNormalizeResult.updatedCount(),
                    assetTypeNormalizeResult.suspiciousCountAfter()
            );
            priceResult = priceSnapshotBatchService.syncSnapshots(priceLimit, true);

            if (priceResult.requestedCount() == 0 || priceResult.savedCount() == 0) {
                return failed(
                        startedAt,
                        priceResult,
                        "PRICE_SNAPSHOTS",
                        "가격 스냅샷을 한 건도 저장하지 못했습니다."
                );
            }

            final List<Long> activeUserIds = userMapper.findActiveUserIdsWithPortfolioItems();
            final RecommendationService.SharedNewsAnalysisWarmupResult sharedNewsWarmup =
                    recommendationService.warmUpSharedNewsAnalysis();
            int recommendationCount = 0;
            int failedUserCount = 0;
            int createdAlertCount = 0;
            int pushSuccessCount = 0;
            int pushFailureCount = 0;
            int failedAlertUserCount = 0;

            log.info(
                    "공용 뉴스 선분석을 완료했습니다. stocks={}, cacheReused={}, refreshed={}, unavailable={}",
                    sharedNewsWarmup.distinctStockCount(),
                    sharedNewsWarmup.cacheReusedCount(),
                    sharedNewsWarmup.refreshedCount(),
                    sharedNewsWarmup.unavailableCount()
            );

            for (Long userId : activeUserIds) {
                try {
                    final List<RecommendationResponse> recommendations =
                            recommendationService.generateLatestRecommendations(
                                    userId,
                                    sharedNewsWarmup.newsByStockId()
                            );
                    recommendationCount += recommendations.size();
                    try {
                        final WeeklyReportService.ImmediateAlertProcessingResult alertResult =
                                weeklyReportService.processImmediateAlerts(
                                        userId,
                                        startedAt.toLocalDate()
                                );
                        createdAlertCount += alertResult.createdCount();
                        pushSuccessCount += alertResult.pushSuccessCount();
                        pushFailureCount += alertResult.pushFailureCount();
                    } catch (Exception exception) {
                        failedAlertUserCount++;
                        log.warn("사용자 일일 변화 알림 처리에 실패했습니다. userId={}", userId, exception);
                    }
                } catch (Exception exception) {
                    failedUserCount++;
                    log.warn("사용자 추천 배치에 실패했습니다. userId={}", userId, exception);
                }
            }

            final String status = priceResult.failedCount() > 0
                    || failedUserCount > 0
                    || failedAlertUserCount > 0
                    || pushFailureCount > 0
                    ? "PARTIAL_SUCCESS"
                    : "SUCCESS";
            final OffsetDateTime finishedAt = OffsetDateTime.now(BATCH_ZONE);

            log.info(
                    "일일 통합 배치를 완료했습니다. status={}, prices={}/{}, users={}, recommendations={}, alerts={}, pushSuccess={}, pushFailure={}, failedUsers={}, failedAlertUsers={}, finishedAt={}",
                    status,
                    priceResult.savedCount(),
                    priceResult.requestedCount(),
                    activeUserIds.size(),
                    recommendationCount,
                    createdAlertCount,
                    pushSuccessCount,
                    pushFailureCount,
                    failedUserCount,
                    failedAlertUserCount,
                    finishedAt
            );
            return new DailyBatchResult(
                    status,
                    startedAt,
                    finishedAt,
                    priceResult,
                    recommendationCount,
                    null,
                    null
            );
        } catch (Exception exception) {
            log.error("일일 통합 배치 실행에 실패했습니다.", exception);
            return failed(
                    startedAt,
                    priceResult,
                    priceResult == null ? "PRICE_SNAPSHOTS" : "RECOMMENDATIONS",
                    rootMessage(exception)
            );
        } finally {
            running.set(false);
        }
    }

    private DailyBatchResult failed(
            OffsetDateTime startedAt,
            PriceSnapshotBatchResult priceResult,
            String failedStage,
            String errorMessage
    ) {
        final OffsetDateTime finishedAt = OffsetDateTime.now(BATCH_ZONE);
        log.error(
                "일일 통합 배치가 실패했습니다. stage={}, message={}, finishedAt={}",
                failedStage,
                errorMessage,
                finishedAt
        );
        return new DailyBatchResult(
                "FAILED",
                startedAt,
                finishedAt,
                priceResult,
                0,
                failedStage,
                errorMessage
        );
    }

    private String rootMessage(Exception exception) {
        Throwable current = exception;
        while (current.getCause() != null) {
            current = current.getCause();
        }
        return current.getMessage() == null
                ? current.getClass().getSimpleName()
                : current.getMessage();
    }
}
