package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.UserAlertEventRecord;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class UserAlertEventServiceTest {

    private final PortfolioInsightMapper mapper = mock(PortfolioInsightMapper.class);
    private final UserAlertEventService service = new UserAlertEventService(mapper);

    @Test
    void unreadAlertIsMarkedAndReturned() {
        final UserAlertEventRecord unread = alert(null);
        final UserAlertEventRecord read = alert(OffsetDateTime.now());
        when(mapper.findAlertById(7L, 31L))
                .thenReturn(Optional.of(unread), Optional.of(read));

        final var response = service.markAsRead(7L, 31L);

        verify(mapper).markAlertRead(7L, 31L);
        assertEquals(31L, response.alertId());
        assertEquals(read.getReadAt(), response.readAt());
    }

    @Test
    void alreadyReadAlertReturnsSuccessWithoutAnotherUpdate() {
        final UserAlertEventRecord read = alert(OffsetDateTime.now());
        when(mapper.findAlertById(7L, 31L)).thenReturn(Optional.of(read));

        final var response = service.markAsRead(7L, 31L);

        verify(mapper, never()).markAlertRead(7L, 31L);
        assertEquals(read.getReadAt(), response.readAt());
    }

    private UserAlertEventRecord alert(OffsetDateTime readAt) {
        final UserAlertEventRecord record = new UserAlertEventRecord();
        record.setId(31L);
        record.setPortfolioItemId(41L);
        record.setStockId(51L);
        record.setAlertType("NEWS_WEAKENED");
        record.setTitle("뉴스 확인");
        record.setBody("관련 뉴스 분위기를 확인해 주세요.");
        record.setReadAt(readAt);
        record.setCreatedAt(OffsetDateTime.now());
        return record;
    }
}
