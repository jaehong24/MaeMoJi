package com.maemoji.backend.stock.service;

import com.maemoji.backend.stock.dto.StockAssetTypeAuditRow;
import com.maemoji.backend.stock.dto.StockAssetTypeNormalizeResult;
import com.maemoji.backend.stock.mapper.StockMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StockAssetTypeMaintenanceService {

    private static final Logger log = LoggerFactory.getLogger(StockAssetTypeMaintenanceService.class);

    private final StockMapper stockMapper;

    @Value("${maemoji.batch.stock-asset-type.enabled:false}")
    private boolean scheduledEnabled;

    public StockAssetTypeMaintenanceService(StockMapper stockMapper) {
        this.stockMapper = stockMapper;
    }

    public List<StockAssetTypeAuditRow> auditSuspiciousAssetTypes(int limit) {
        final int safeLimit = Math.max(1, Math.min(limit, 500));
        return stockMapper.findSuspiciousAssetTypeStocks(safeLimit);
    }

    public StockAssetTypeNormalizeResult normalizeAssetTypes() {
        final int suspiciousCountBefore = stockMapper.countSuspiciousAssetTypeStocks();
        final int updatedCount = stockMapper.normalizeAssetTypes();
        final int suspiciousCountAfter = stockMapper.countSuspiciousAssetTypeStocks();
        final List<StockAssetTypeAuditRow> suspiciousPreview =
                stockMapper.findSuspiciousAssetTypeStocks(50);

        log.info(
                "종목 asset_type 보정 배치를 완료했습니다. suspiciousBefore={}, updated={}, suspiciousAfter={}",
                suspiciousCountBefore,
                updatedCount,
                suspiciousCountAfter
        );

        return new StockAssetTypeNormalizeResult(
                suspiciousCountBefore,
                updatedCount,
                suspiciousCountAfter,
                suspiciousPreview
        );
    }

    @Scheduled(cron = "${maemoji.batch.stock-asset-type.cron:0 20 4 * * *}")
    public void normalizeAssetTypesOnSchedule() {
        if (!scheduledEnabled) {
            return;
        }

        try {
            normalizeAssetTypes();
        } catch (Exception exception) {
            log.warn("종목 asset_type 보정 스케줄 실행 중 오류가 발생했습니다.", exception);
        }
    }
}
