package com.maemoji.backend.portfolio.service;

import com.maemoji.backend.portfolio.dto.PortfolioCreateRequest;
import com.maemoji.backend.portfolio.dto.PortfolioItemSummaryResponse;
import com.maemoji.backend.portfolio.mapper.PortfolioMapper;
import com.maemoji.backend.user.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class PortfolioService {

    private static final String DEV_USER_EMAIL = "dev@maemoji.local";
    private static final int MAX_PORTFOLIO_ITEMS = 5;

    private final PortfolioMapper portfolioMapper;
    private final UserMapper userMapper;

    public PortfolioService(PortfolioMapper portfolioMapper, UserMapper userMapper) {
        this.portfolioMapper = portfolioMapper;
        this.userMapper = userMapper;
    }

    @Transactional
    public List<PortfolioItemSummaryResponse> createOrUpdatePortfolioItem(
            PortfolioCreateRequest request
    ) {
        validateDailyInvestAmount(request);

        final Long userId = ensureDevUserId();
        final Long portfolioItemId = portfolioMapper.findPortfolioItemIdByUserIdAndStockId(
                userId,
                request.stockId()
        );

        if (portfolioItemId == null) {
            final int activeItemCount = portfolioMapper.countActivePortfolioItemsByUserId(userId);
            if (activeItemCount >= MAX_PORTFOLIO_ITEMS) {
                throw new ResponseStatusException(
                        BAD_REQUEST,
                        "모으기 종목은 최대 5개까지만 저장할 수 있습니다."
                );
            }

            portfolioMapper.insertPortfolioItem(userId, request);
        } else {
            portfolioMapper.updatePortfolioItem(portfolioItemId, request);
        }

        return portfolioMapper.findPortfolioItemsByUserId(userId);
    }

    @Transactional
    public List<PortfolioItemSummaryResponse> deletePortfolioItem(Long portfolioItemId) {
        final Long userId = ensureDevUserId();
        final int updatedCount = portfolioMapper.deactivatePortfolioItem(userId, portfolioItemId);

        if (updatedCount == 0) {
            throw new ResponseStatusException(NOT_FOUND, "삭제할 포트폴리오 종목을 찾을 수 없습니다.");
        }

        return portfolioMapper.findPortfolioItemsByUserId(userId);
    }

    public List<PortfolioItemSummaryResponse> getPortfolioItems() {
        return portfolioMapper.findPortfolioItemsByUserId(ensureDevUserId());
    }

    private void validateDailyInvestAmount(PortfolioCreateRequest request) {
        if (request.dailyInvestAmount() != null
                && request.dailyInvestAmount().compareTo(java.math.BigDecimal.valueOf(100)) > 0) {
            throw new ResponseStatusException(
                    BAD_REQUEST,
                    "매일 모으기 금액은 최대 100달러까지만 입력할 수 있습니다."
            );
        }
    }

    private Long ensureDevUserId() {
        Long userId = userMapper.findIdByEmail(DEV_USER_EMAIL);

        if (userId != null) {
            return userId;
        }

        userMapper.insertDevUser();
        userId = userMapper.findIdByEmail(DEV_USER_EMAIL);

        if (userId == null) {
            throw new IllegalStateException("개발용 사용자를 찾을 수 없습니다.");
        }

        return userId;
    }
}
