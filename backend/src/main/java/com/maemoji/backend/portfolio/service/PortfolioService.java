package com.maemoji.backend.portfolio.service;

import com.maemoji.backend.portfolio.dto.PortfolioCreateRequest;
import com.maemoji.backend.portfolio.dto.PortfolioItemSummaryResponse;
import com.maemoji.backend.portfolio.mapper.PortfolioMapper;
import org.springframework.stereotype.Service;
import org.springframework.core.task.TaskRejectedException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class PortfolioService {

    private static final int MAX_PORTFOLIO_ITEMS = 5;
    private static final Logger log = LoggerFactory.getLogger(PortfolioService.class);

    private final PortfolioMapper portfolioMapper;
    private final PortfolioWarmupService portfolioWarmupService;

    public PortfolioService(
            PortfolioMapper portfolioMapper,
            PortfolioWarmupService portfolioWarmupService
    ) {
        this.portfolioMapper = portfolioMapper;
        this.portfolioWarmupService = portfolioWarmupService;
    }

    @Transactional
    public List<PortfolioItemSummaryResponse> createOrUpdatePortfolioItem(
            Long userId,
            PortfolioCreateRequest request
    ) {
        validateDailyInvestAmount(request);
        portfolioMapper.lockUserPortfolio(userId);
        if (!portfolioMapper.isActiveStock(request.stockId())) {
            throw new ResponseStatusException(NOT_FOUND, "등록 가능한 종목을 찾을 수 없습니다.");
        }

        final Long portfolioItemId = portfolioMapper.findPortfolioItemIdByUserIdAndStockId(
                userId,
                request.stockId()
        );

        if (portfolioItemId == null || !portfolioMapper.isActivePortfolioItem(userId, portfolioItemId)) {
            final int activeItemCount = portfolioMapper.countActivePortfolioItemsByUserId(userId);
            if (activeItemCount >= MAX_PORTFOLIO_ITEMS) {
                throw new ResponseStatusException(
                        BAD_REQUEST,
                        "모으기 종목은 최대 5개까지만 등록할 수 있습니다."
                );
            }
        }
        if (portfolioItemId == null) {
            portfolioMapper.insertPortfolioItem(userId, request);
        } else {
            portfolioMapper.updatePortfolioItem(portfolioItemId, request);
        }

        registerAfterCommitWarmup(userId, request.stockId());
        return portfolioMapper.findPortfolioItemsByUserId(userId);
    }

    @Transactional
    public List<PortfolioItemSummaryResponse> deletePortfolioItem(Long userId, Long portfolioItemId) {
        final int updatedCount = portfolioMapper.deactivatePortfolioItem(userId, portfolioItemId);

        if (updatedCount == 0) {
            throw new ResponseStatusException(NOT_FOUND, "삭제할 포트폴리오 종목을 찾을 수 없습니다.");
        }

        return portfolioMapper.findPortfolioItemsByUserId(userId);
    }

    public List<PortfolioItemSummaryResponse> getPortfolioItems(Long userId) {
        return portfolioMapper.findPortfolioItemsByUserId(userId);
    }

    private void validateDailyInvestAmount(PortfolioCreateRequest request) {
        if (request.dailyInvestAmount() != null
                && request.dailyInvestAmount().compareTo(BigDecimal.valueOf(100)) > 0) {
            throw new ResponseStatusException(
                    BAD_REQUEST,
                "매일 모으기 금액은 최대 100달러까지만 입력할 수 있습니다."
            );
        }
    }

    private void registerAfterCommitWarmup(Long userId, Long stockId) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            enqueueWarmup(userId, stockId);
            return;
        }

        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                enqueueWarmup(userId, stockId);
            }
        });
    }

    private void enqueueWarmup(Long userId, Long stockId) {
        try {
            portfolioWarmupService.warmUpAfterPortfolioSaved(userId, stockId);
        } catch (TaskRejectedException exception) {
            // The transaction already committed; the daily run can pick up the saved item.
            log.warn("즉시 분석 대기열이 가득 찼습니다. 정기 분석에서 재처리합니다. userId={}, stockId={}", userId, stockId);
        }
    }
}
