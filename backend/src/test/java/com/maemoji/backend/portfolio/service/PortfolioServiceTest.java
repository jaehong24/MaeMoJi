package com.maemoji.backend.portfolio.service;

import com.maemoji.backend.portfolio.dto.PortfolioCreateRequest;
import com.maemoji.backend.portfolio.dto.PortfolioItemSummaryResponse;
import com.maemoji.backend.portfolio.mapper.PortfolioMapper;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class PortfolioServiceTest {

    private final PortfolioMapper portfolioMapper = mock(PortfolioMapper.class);
    private final PortfolioWarmupService portfolioWarmupService = mock(PortfolioWarmupService.class);
    private final PortfolioService portfolioService = new PortfolioService(
            portfolioMapper,
            portfolioWarmupService
    );

    @Test
    void createPortfolioItemTriggersImmediateSnapshotWarmup() {
        final PortfolioCreateRequest request = createRequest(4083L);
        final List<PortfolioItemSummaryResponse> summaries = List.of(
                new PortfolioItemSummaryResponse(
                        1001L,
                        4083L,
                        "Meta Platforms",
                        "META",
                        "NASDAQ",
                        BigDecimal.valueOf(15),
                        BigDecimal.ZERO,
                        LocalDate.of(2026, 6, 17),
                        "test",
                        "https://example.com/meta.png"
                )
        );

        when(portfolioMapper.findPortfolioItemIdByUserIdAndStockId(1L, 4083L)).thenReturn(null);
        when(portfolioMapper.countActivePortfolioItemsByUserId(1L)).thenReturn(1);
        when(portfolioMapper.findPortfolioItemsByUserId(1L)).thenReturn(summaries);

        TransactionSynchronizationManager.initSynchronization();
        try {
            final List<PortfolioItemSummaryResponse> result =
                    portfolioService.createOrUpdatePortfolioItem(1L, request);

            assertThat(result).hasSize(1);
            verify(portfolioMapper).insertPortfolioItem(1L, request);
            verify(portfolioWarmupService, never()).warmUpAfterPortfolioSaved(1L, 4083L);

            for (TransactionSynchronization synchronization : TransactionSynchronizationManager.getSynchronizations()) {
                synchronization.afterCommit();
            }

            verify(portfolioWarmupService).warmUpAfterPortfolioSaved(1L, 4083L);
        } finally {
            TransactionSynchronizationManager.clearSynchronization();
        }
    }

    @Test
    void createPortfolioItemSchedulesWarmupEvenWhenAsyncWorkMayFailLater() {
        final PortfolioCreateRequest request = createRequest(4090L);
        final List<PortfolioItemSummaryResponse> summaries = List.of();

        when(portfolioMapper.findPortfolioItemIdByUserIdAndStockId(7L, 4090L)).thenReturn(null);
        when(portfolioMapper.countActivePortfolioItemsByUserId(7L)).thenReturn(0);
        when(portfolioMapper.findPortfolioItemsByUserId(7L)).thenReturn(summaries);

        TransactionSynchronizationManager.initSynchronization();
        try {
            final List<PortfolioItemSummaryResponse> result =
                    portfolioService.createOrUpdatePortfolioItem(7L, request);

            assertThat(result).isEmpty();
            verify(portfolioMapper).insertPortfolioItem(7L, request);
            verify(portfolioMapper, never()).updatePortfolioItem(anyLong(), org.mockito.ArgumentMatchers.any());

            for (TransactionSynchronization synchronization : TransactionSynchronizationManager.getSynchronizations()) {
                synchronization.afterCommit();
            }

            verify(portfolioWarmupService).warmUpAfterPortfolioSaved(7L, 4090L);
        } finally {
            TransactionSynchronizationManager.clearSynchronization();
        }
    }

    private PortfolioCreateRequest createRequest(Long stockId) {
        return new PortfolioCreateRequest(
                stockId,
                BigDecimal.valueOf(15),
                BigDecimal.ZERO,
                LocalDate.of(2026, 6, 17),
                "test"
        );
    }
}
