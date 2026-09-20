package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.UserAlertEventRecord;
import com.maemoji.backend.portfolioinsight.domain.UserDeviceTokenRecord;
import com.maemoji.backend.portfolioinsight.domain.UserNotificationPreferenceRecord;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class PushNotificationDispatchServiceTest {

    @Test
    void testPushDoesNotExposeProviderException() throws Exception {
        when(gateway.sendEach(anyList())).thenThrow(new IllegalStateException("private credential detail"));
        final var result = service.sendTestPush(7L, null);
        org.assertj.core.api.Assertions.assertThat(result.toString()).doesNotContain("private credential detail");
        org.assertj.core.api.Assertions.assertThat(result.toString()).contains("잠시 후 다시 시도해주세요");
    }

    private final PortfolioInsightMapper mapper = mock(PortfolioInsightMapper.class);
    private final PushNotificationPolicyService policy = mock(PushNotificationPolicyService.class);
    private final FirebaseMessagingGateway gateway = mock(FirebaseMessagingGateway.class);
    private final PushDeliveryOutboxNotifier outboxNotifier = mock(PushDeliveryOutboxNotifier.class);
    private final PushNotificationDispatchService service =
            new PushNotificationDispatchService(mapper, policy, gateway, outboxNotifier);

    private UserAlertEventRecord alert;
    private UserDeviceTokenRecord device;

    @BeforeEach
    void setUp() {
        alert = new UserAlertEventRecord();
        alert.setId(31L);
        alert.setPortfolioItemId(41L);
        alert.setStockId(51L);
        alert.setAlertType("PRICE_RISK");
        alert.setTitle("가격 흐름 확인");
        alert.setBody("가격 변동성이 커졌어요.");

        device = new UserDeviceTokenRecord();
        device.setId(61L);
        device.setUserId(7L);
        device.setFcmToken("expired-token");
        device.setIsActive(true);
        device.setPushEnabled(true);

        when(mapper.findNotificationPreferenceByUserId(7L))
                .thenReturn(new UserNotificationPreferenceRecord());
        when(policy.isImmediatePushEligible(any(), any())).thenReturn(true);
        when(policy.isSuppressedByQuietHours(any(), any())).thenReturn(false);
        when(policy.isWithinCooldown(any(), any(), any())).thenReturn(false);
        when(policy.resolveNotificationKind(any())).thenReturn("IMMEDIATE");
        when(mapper.findDeviceTokensByUserId(7L)).thenReturn(List.of(device));
        when(mapper.insertPushNotificationDelivery(
                anyLong(), org.mockito.ArgumentMatchers.isNull(), anyLong(), anyLong(), anyString(), anyString(),
                anyString(), anyString(), anyString(), anyString()
        )).thenReturn(1);
    }

    @Test
    void immediateAlertIsQueuedBeforeTheOutboxWorkerSendsIt() throws Exception {
        final var result = service.dispatchImmediate(7L, alert);

        org.assertj.core.api.Assertions.assertThat(result.dispatched()).isTrue();
        verify(outboxNotifier).requestDispatchAfterCommit();
        verify(gateway, never()).sendEach(anyList());
        verify(mapper, never()).deactivateDeviceToken(anyLong(), anyString(), any());
    }
}
