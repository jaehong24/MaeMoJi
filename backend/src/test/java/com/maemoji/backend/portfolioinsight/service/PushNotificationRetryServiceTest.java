package com.maemoji.backend.portfolioinsight.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.common.startup.PushNotificationSchemaInitializer;
import com.maemoji.backend.portfolioinsight.domain.RetryablePushDeliveryRecord;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.junit.jupiter.api.Test;
import java.util.List;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class PushNotificationRetryServiceTest {
    private final PushNotificationSchemaInitializer schema = mock(PushNotificationSchemaInitializer.class);
    private final PortfolioInsightMapper mapper = mock(PortfolioInsightMapper.class);
    private final FirebaseMessagingGateway gateway = mock(FirebaseMessagingGateway.class);
    private final PushNotificationPolicyService policy = mock(PushNotificationPolicyService.class);
    private final PushDeliveryOutboxNotifier outboxNotifier = mock(PushDeliveryOutboxNotifier.class);
    private final PushNotificationDispatchService dispatch =
            new PushNotificationDispatchService(mapper, policy, gateway, outboxNotifier);
    private final PushNotificationRetryService service = new PushNotificationRetryService(
            mapper, gateway, new ObjectMapper(), dispatch, schema
    );

    @Test
    void claimsAndMarksSuccessfulRetry() throws Exception {
        when(schema.isReady()).thenReturn(true);
        final RetryablePushDeliveryRecord delivery = delivery();
        when(mapper.findRetryablePushDeliveries(50)).thenReturn(List.of(delivery));
        when(mapper.claimPushNotificationDelivery(10L)).thenReturn(1);
        when(gateway.sendEach(anyList())).thenReturn(List.of(
                FirebaseMessagingGateway.SendResult.success("message-1")
        ));

        service.retryFailedDeliveries();

        verify(mapper).updatePushNotificationDeliverySuccess(eq("dedupe-10"), eq("message-1"), any());
        verify(mapper, never()).deactivateDeviceToken(anyLong(), anyString(), any());
    }

    @Test
    void sendsQueuedDeliveryOnlyAfterTheOutboxWorkerClaimsIt() throws Exception {
        when(schema.isReady()).thenReturn(true);
        final RetryablePushDeliveryRecord delivery = delivery();
        delivery.setWeeklyReportId(51L);
        when(mapper.findPendingPushDeliveries(50)).thenReturn(List.of(delivery));
        when(mapper.claimPendingPushNotificationDelivery(10L)).thenReturn(1);
        when(gateway.sendEach(anyList())).thenReturn(List.of(
                FirebaseMessagingGateway.SendResult.success("message-queued")
        ));

        service.retryFailedDeliveries();

        verify(mapper).updatePushNotificationDeliverySuccess(eq("dedupe-10"), eq("message-queued"), any());
        verify(mapper).refreshWeeklyNotificationJobDeliveryResult(51L);
    }

    @Test
    void permanentlyInvalidRetryTokenIsDisabled() throws Exception {
        when(schema.isReady()).thenReturn(true);
        final RetryablePushDeliveryRecord delivery = delivery();
        when(mapper.findRetryablePushDeliveries(50)).thenReturn(List.of(delivery));
        when(mapper.claimPushNotificationDelivery(10L)).thenReturn(1);
        when(gateway.sendEach(anyList())).thenReturn(List.of(
                FirebaseMessagingGateway.SendResult.failure("UNREGISTERED", "expired")
        ));

        service.retryFailedDeliveries();

        verify(mapper).deactivateDeviceToken(eq(7L), eq("token-10"), any());
        verify(mapper).markPushNotificationDeliveryPermanentFailure(
                eq("dedupe-10"), eq("UNREGISTERED"), eq("expired"), any()
        );
        verify(mapper, never()).updatePushNotificationDeliveryFailure(anyString(), anyString(), anyString(), any());
    }

    @Test
    void storesSafeFailureDetailsWhenRetryProcessingThrows() throws Exception {
        when(schema.isReady()).thenReturn(true);
        final RetryablePushDeliveryRecord delivery = delivery();
        when(mapper.findRetryablePushDeliveries(50)).thenReturn(List.of(delivery));
        when(mapper.claimPushNotificationDelivery(10L)).thenReturn(1);
        when(gateway.sendEach(anyList())).thenThrow(new IllegalStateException("Firebase temporarily unavailable"));

        service.retryFailedDeliveries();

        verify(mapper).updatePushNotificationDeliveryFailure(
                eq("dedupe-10"), eq("RETRY_ERROR"), contains("IllegalStateException"), any()
        );
    }

    @Test
    void doesNotQueryDatabaseBeforeSchemaIsReady() {
        service.retryFailedDeliveries();
        verifyNoInteractions(mapper, gateway);
    }

    private RetryablePushDeliveryRecord delivery() {
        final RetryablePushDeliveryRecord delivery = new RetryablePushDeliveryRecord();
        delivery.setId(10L);
        delivery.setUserId(7L);
        delivery.setFcmToken("token-10");
        delivery.setDedupeKey("dedupe-10");
        delivery.setTitle("title");
        delivery.setBody("body");
        delivery.setPayloadJson("{\"type\":\"ALERT_EVENT\"}");
        return delivery;
    }
}
