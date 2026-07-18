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

    private final PortfolioInsightMapper mapper = mock(PortfolioInsightMapper.class);
    private final PushNotificationPolicyService policy = mock(PushNotificationPolicyService.class);
    private final FirebaseMessagingGateway gateway = mock(FirebaseMessagingGateway.class);
    private final PushNotificationDispatchService service =
            new PushNotificationDispatchService(mapper, policy, gateway);

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
                anyLong(), anyLong(), anyLong(), anyString(), anyString(),
                anyString(), anyString(), anyString(), anyString()
        )).thenReturn(1);
    }

    @Test
    void unregisteredTokenIsDeactivated() throws Exception {
        when(gateway.sendEach(anyList())).thenReturn(List.of(
                FirebaseMessagingGateway.SendResult.failure("UNREGISTERED", "등록 해제된 토큰")
        ));

        service.dispatchImmediate(7L, alert);

        verify(mapper).deactivateDeviceToken(anyLong(), anyString(), any());
        verify(mapper).updatePushNotificationDeliveryFailure(
                anyString(), anyString(), anyString(), any()
        );
    }

    @Test
    void temporaryFirebaseFailureKeepsTokenActive() throws Exception {
        when(gateway.sendEach(anyList())).thenReturn(List.of(
                FirebaseMessagingGateway.SendResult.failure("UNAVAILABLE", "일시적인 서버 오류")
        ));

        service.dispatchImmediate(7L, alert);

        verify(mapper, never()).deactivateDeviceToken(anyLong(), anyString(), any());
        verify(mapper).updatePushNotificationDeliveryFailure(
                anyString(), anyString(), anyString(), any()
        );
    }
}
