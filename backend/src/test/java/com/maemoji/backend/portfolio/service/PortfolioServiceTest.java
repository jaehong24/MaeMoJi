package com.maemoji.backend.portfolio.service;

import com.maemoji.backend.portfolio.dto.PortfolioCreateRequest;
import com.maemoji.backend.portfolio.dto.PortfolioItemSummaryResponse;
import com.maemoji.backend.portfolio.mapper.PortfolioMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.core.task.TaskRejectedException;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doThrow;
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

    @BeforeEach
    void activeStocksAreAvailable() {
        when(portfolioMapper.isActiveStock(anyLong())).thenReturn(true);
    }

    @Test
    void inactiveItemCannotBypassFiveItemLimit() {
        when(portfolioMapper.findPortfolioItemIdByUserIdAndStockId(1L, 2L)).thenReturn(3L);
        when(portfolioMapper.countActivePortfolioItemsByUserId(1L)).thenReturn(5);
        assertThatThrownBy(() -> portfolioService.createOrUpdatePortfolioItem(1L, createRequest(2L)))
                .isInstanceOfSatisfying(ResponseStatusException.class,
                        error -> assertThat(error.getStatusCode().value()).isEqualTo(400));
        verify(portfolioMapper, never()).updatePortfolioItem(anyLong(), org.mockito.ArgumentMatchers.any());
        verify(portfolioWarmupService, never()).warmUpAfterPortfolioSaved(anyLong(), anyLong());
    }

    @Test
    void activeItemCanStillBeEditedAtLimit() {
        when(portfolioMapper.findPortfolioItemIdByUserIdAndStockId(1L, 2L)).thenReturn(3L);
        when(portfolioMapper.isActivePortfolioItem(1L, 3L)).thenReturn(true);
        portfolioService.createOrUpdatePortfolioItem(1L, createRequest(2L));
        verify(portfolioMapper).updatePortfolioItem(3L, createRequest(2L));
        verify(portfolioMapper, never()).countActivePortfolioItemsByUserId(1L);
    }

    @Test
    void inactiveItemCanBeReactivatedBelowLimit() {
        when(portfolioMapper.findPortfolioItemIdByUserIdAndStockId(1L, 2L)).thenReturn(3L);
        when(portfolioMapper.countActivePortfolioItemsByUserId(1L)).thenReturn(4);
        portfolioService.createOrUpdatePortfolioItem(1L, createRequest(2L));
        verify(portfolioMapper).lockUserPortfolio(1L);
        verify(portfolioMapper).updatePortfolioItem(3L, createRequest(2L));
    }

    @Test
    void missingStockIsNotReportedAsDatabaseFailure() {
        when(portfolioMapper.isActiveStock(2L)).thenReturn(false);
        assertThatThrownBy(() -> portfolioService.createOrUpdatePortfolioItem(1L, createRequest(2L)))
                .isInstanceOfSatisfying(ResponseStatusException.class,
                        error -> assertThat(error.getStatusCode().value()).isEqualTo(404));
        verify(portfolioMapper, never()).insertPortfolioItem(anyLong(), org.mockito.ArgumentMatchers.any());
    }

    @Test
    void fullWarmupQueueDoesNotTurnCommittedSaveIntoError() {
        when(portfolioMapper.findPortfolioItemIdByUserIdAndStockId(1L, 2L)).thenReturn(null);
        doThrow(new TaskRejectedException("full"))
                .when(portfolioWarmupService).warmUpAfterPortfolioSaved(1L, 2L);
        TransactionSynchronizationManager.initSynchronization();
        try {
            portfolioService.createOrUpdatePortfolioItem(1L, createRequest(2L));
            verify(portfolioMapper).insertPortfolioItem(1L, createRequest(2L));
            for (TransactionSynchronization synchronization : TransactionSynchronizationManager.getSynchronizations()) {
                synchronization.afterCommit();
            }
        } finally {
            TransactionSynchronizationManager.clearSynchronization();
        }
    }

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
