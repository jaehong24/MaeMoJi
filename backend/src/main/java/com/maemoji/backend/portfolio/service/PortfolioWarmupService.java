package com.maemoji.backend.portfolio.service;

import com.maemoji.backend.recommendation.service.RecommendationService;
import com.maemoji.backend.stock.service.StockPriceSnapshotBatchService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class PortfolioWarmupService {

    private static final Logger log = LoggerFactory.getLogger(PortfolioWarmupService.class);

    private final RecommendationService recommendationService;
    private final StockPriceSnapshotBatchService stockPriceSnapshotBatchService;

    public PortfolioWarmupService(
            RecommendationService recommendationService,
            StockPriceSnapshotBatchService stockPriceSnapshotBatchService
    ) {
        this.recommendationService = recommendationService;
        this.stockPriceSnapshotBatchService = stockPriceSnapshotBatchService;
    }

    @Async("portfolioWarmupExecutor")
    public void warmUpAfterPortfolioSaved(Long userId, Long stockId) {
        try {
            stockPriceSnapshotBatchService.syncLatestSnapshotForStock(stockId);
        } catch (Exception exception) {
            log.warn(
                    "포트폴리오 저장 직후 가격 스냅샷 선반영에 실패했습니다. userId={}, stockId={}",
                    userId,
                    stockId,
                    exception
            );
        }

        try {
            recommendationService.warmUpLatestNewsForUserStock(userId, stockId);
        } catch (Exception exception) {
            log.warn(
                    "포트폴리오 저장 직후 뉴스 선분석에 실패했습니다. userId={}, stockId={}",
                    userId,
                    stockId,
                    exception
            );
        }

        try {
            recommendationService.generateLatestRecommendationsFromCachedData(userId);
        } catch (Exception exception) {
            log.warn(
                    "포트폴리오 저장 직후 추천 재계산에 실패했습니다. userId={}, stockId={}",
                    userId,
                    stockId,
                    exception
            );
        }
    }
}
