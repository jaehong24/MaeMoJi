package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import com.maemoji.backend.portfolioinsight.dto.WeeklyReportResponse;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class WeeklyDigestNotificationServiceTest {

    private final PortfolioInsightMapper mapper = mock(PortfolioInsightMapper.class);
    private final FirebaseMessagingGateway gateway = mock(FirebaseMessagingGateway.class);
    private final WeeklyDigestNotificationService service = new WeeklyDigestNotificationService(
            mapper,
            new PushNotificationPolicyService(),
            gateway
    );

    @Test
    void 실제변화가없으면주간푸시를보내지않는다() throws Exception {
        final UserNotificationPreferenceRecord preference = new UserNotificationPreferenceRecord();
        preference.setWeeklyDigestEnabled(true);
        final WeeklyReportResponse report = new WeeklyReportResponse(
                11L,
                LocalDate.of(2026, 7, 13),
                OffsetDateTime.now(),
                "큰 변화 없이 유지되고 있어요",
                "이번 주에는 중요한 변화가 없었어요.",
                0,
                0,
                0,
                0,
                List.of()
        );
        when(mapper.findNotificationPreferenceByUserId(7L)).thenReturn(preference);
        when(mapper.findDeviceTokensByUserId(7L)).thenReturn(List.of());
        when(mapper.insertWeeklyNotificationJobIfAbsent(eq(7L), eq(11L), eq(report.reportWeek()), any()))
                .thenReturn(1);

        final WeeklyDigestNotificationService.WeeklyDigestDispatchResult result =
                service.dispatchWeeklyDigest(7L, report);

        assertThat(result.dispatched()).isFalse();
        assertThat(result.message()).contains("중요한 변화가 없어");
        verify(mapper).updateWeeklyNotificationJobResult(
                eq(7L),
                eq(report.reportWeek()),
                eq("NO_CHANGE"),
                eq(0),
                eq(0),
                eq(0),
                any(),
                any(),
                any()
        );
        verify(gateway, never()).sendEach(any());
    }
}
