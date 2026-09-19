package com.maemoji.backend.portfolioinsight.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.Message;
import com.maemoji.backend.portfolioinsight.domain.RetryablePushDeliveryRecord;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;

@Service
@ConditionalOnProperty(name = "maemoji.notifications.retry.enabled", havingValue = "true", matchIfMissing = true)
public class PushNotificationRetryService {
    private static final Logger log = LoggerFactory.getLogger(PushNotificationRetryService.class);
    private static final int MAX_BATCH = 50;
    private final PortfolioInsightMapper mapper;
    private final FirebaseMessagingGateway gateway;
    private final ObjectMapper objectMapper;
    private final PushNotificationDispatchService dispatchService;

    public PushNotificationRetryService(
            PortfolioInsightMapper mapper,
            FirebaseMessagingGateway gateway,
            ObjectMapper objectMapper,
            PushNotificationDispatchService dispatchService
    ) {
        this.mapper = mapper;
        this.gateway = gateway;
        this.objectMapper = objectMapper;
        this.dispatchService = dispatchService;
    }

    @Scheduled(fixedDelayString = "${MAEMOJI_PUSH_RETRY_DELAY_MILLIS:60000}")
    public void retryFailedDeliveries() {
        mapper.recoverStalePushNotificationDeliveries();
        final List<RetryablePushDeliveryRecord> candidates = mapper.findRetryablePushDeliveries(MAX_BATCH);
        for (RetryablePushDeliveryRecord delivery : candidates) {
            if (mapper.claimPushNotificationDelivery(delivery.getId()) != 1) {
                continue;
            }
            retryOne(delivery);
        }
    }

    private void retryOne(RetryablePushDeliveryRecord delivery) {
        try {
            final Map<String, String> data = objectMapper.readValue(
                    delivery.getPayloadJson() == null ? "{}" : delivery.getPayloadJson(),
                    new TypeReference<>() { }
            );
            final Message message = dispatchService.buildRetryMessage(
                    delivery.getFcmToken(), delivery.getTitle(), delivery.getBody(), data
            );
            final FirebaseMessagingGateway.SendResult result = gateway.sendEach(List.of(message)).get(0);
            final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));
            if (result.successful()) {
                mapper.updatePushNotificationDeliverySuccess(delivery.getDedupeKey(), result.messageId(), now);
            } else {
                mapper.updatePushNotificationDeliveryFailure(
                        delivery.getDedupeKey(), result.errorCode(), result.errorMessage(), now
                );
                if (isPermanent(result.errorCode())) {
                    mapper.deactivateDeviceToken(delivery.getUserId(), delivery.getFcmToken(), now);
                }
            }
        } catch (Exception exception) {
            final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));
            mapper.updatePushNotificationDeliveryFailure(delivery.getDedupeKey(), "RETRY_ERROR", "retry failed", now);
            log.warn("푸시 재시도에 실패했습니다. deliveryId={}", delivery.getId());
        }
    }

    private boolean isPermanent(String code) {
        return "UNREGISTERED".equals(code)
                || "SENDER_ID_MISMATCH".equals(code)
                || "registration-token-not-registered".equals(code)
                || "mismatched-credential".equals(code);
    }
}
