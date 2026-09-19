package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.dto.PortfolioReasonUpdateRequest;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class PortfolioInsightServiceTest {

    private final PortfolioInsightMapper mapper = mock(PortfolioInsightMapper.class);
    private final PortfolioInsightService service = new PortfolioInsightService(mapper);

    @Test
    void anotherUsersPortfolioReasonsCannotBeReadOrChanged() {
        when(mapper.findOwnedActivePortfolioItemId(8L, 41L)).thenReturn(null);

        assertThatThrownBy(() -> service.getPortfolioReasons(8L, 41L))
                .isInstanceOfSatisfying(ResponseStatusException.class,
                        error -> assertEquals(404, error.getStatusCode().value()));
        assertThatThrownBy(() -> service.updatePortfolioReasons(
                8L,
                41L,
                new PortfolioReasonUpdateRequest(List.of("LONG_TERM_GROWTH"))
        )).isInstanceOfSatisfying(ResponseStatusException.class,
                error -> assertEquals(404, error.getStatusCode().value()));

        verify(mapper, never()).deletePortfolioReasons(anyLong());
        verify(mapper, never()).insertPortfolioReason(anyLong(), org.mockito.ArgumentMatchers.anyString(), org.mockito.ArgumentMatchers.anyInt());
        verify(mapper, never()).findPortfolioReasons(anyLong(), anyLong());
    }
}
