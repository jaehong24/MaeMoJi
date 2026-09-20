package com.maemoji.backend.portfolioinsight.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.Message;
import com.maemoji.backend.portfolioinsight.domain.RetryablePushDeliveryRecord;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import com.maemoji.backend.common.startup.PushNotificationSchemaInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Locale;
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
    private final PushNotificationSchemaInitializer schemaInitializer;

    public PushNotificationRetryService(
            PortfolioInsightMapper mapper,
            FirebaseMessagingGateway gateway,
            ObjectMapper objectMapper,
            PushNotificationDispatchService dispatchService,
            PushNotificationSchemaInitializer schemaInitializer
    ) {
        this.mapper = mapper;
        this.gateway = gateway;
        this.objectMapper = objectMapper;
        this.dispatchService = dispatchService;
        this.schemaInitializer = schemaInitializer;
    }

    @Scheduled(fixedDelayString = "${MAEMOJI_PUSH_RETRY_DELAY_MILLIS:60000}")
    public void retryFailedDeliveries() {
        dispatchPendingAndRetryDeliveries();
    }

    // Scheduled polling uses a fresh thread/connection after the producer transaction ends.
    public void dispatchQueuedDeliveries(PushDeliveryQueuedEvent ignored) {
        // The durable PENDING row is sufficient; never dispatch inside afterCommit callbacks.
    }

    private void dispatchPendingAndRetryDeliveries() {
        if (!schemaInitializer.isReady()) {
            return;
        }
        mapper.recoverStalePushNotificationDeliveries();
        final List<RetryablePushDeliveryRecord> pendingCandidates = mapper.findPendingPushDeliveries(MAX_BATCH);
        for (RetryablePushDeliveryRecord delivery : pendingCandidates) {
            if (mapper.claimPendingPushNotificationDelivery(delivery.getId()) != 1) {
                continue;
            }
            sendDelivery(delivery);
        }
        final List<RetryablePushDeliveryRecord> candidates = mapper.findRetryablePushDeliveries(MAX_BATCH);
        for (RetryablePushDeliveryRecord delivery : candidates) {
            if (mapper.claimPushNotificationDelivery(delivery.getId()) != 1) {
                continue;
            }
            sendDelivery(delivery);
        }
    }

    private void sendDelivery(RetryablePushDeliveryRecord delivery) {
        try {
            final Map<String, String> data = objectMapper.readValue(
                    delivery.getPayloadJson() == null ? "{}" : delivery.getPayloadJson(),
                    new TypeReference<>() { }
            );
            final Message message = dispatchService.buildRetryMessage(
                    delivery.getFcmToken(),
                    delivery.getTitle(),
                    delivery.getBody(),
                    data,
                    delivery.getNotificationKind()
            );
            final FirebaseMessagingGateway.SendResult result = gateway.sendEach(List.of(message)).get(0);
            final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));
            if (result.successful()) {
                mapper.updatePushNotificationDeliverySuccess(delivery.getDedupeKey(), result.messageId(), now);
            } else if (isPermanentTokenFailure(result.errorCode(), result.errorMessage())) {
                mapper.markPushNotificationDeliveryPermanentFailure(
                        delivery.getDedupeKey(), safeErrorCode(result.errorCode()), safeErrorMessage(result.errorMessage()), now
                );
                mapper.deactivateDeviceToken(delivery.getUserId(), delivery.getFcmToken(), now);
                log.info("만료되었거나 유효하지 않은 푸시 토큰을 비활성화했습니다. deliveryId={}, errorCode={}",
                        delivery.getId(), safeErrorCode(result.errorCode()));
            } else {
                mapper.updatePushNotificationDeliveryFailure(
                        delivery.getDedupeKey(), safeErrorCode(result.errorCode()), safeErrorMessage(result.errorMessage()), now
                );
                log.warn("푸시 재시도가 일시적으로 실패했습니다. deliveryId={}, errorCode={}",
                        delivery.getId(), safeErrorCode(result.errorCode()));
            }
            refreshWeeklyJobIfNeeded(delivery);
        } catch (Exception exception) {
            final OffsetDateTime now = OffsetDateTime.now(ZoneId.of(PushNotificationSettingsService.DEFAULT_TIMEZONE));
            final String failureDetail = exception.getClass().getSimpleName() + ": " + safeExceptionMessage(exception);
            mapper.updatePushNotificationDeliveryFailure(delivery.getDedupeKey(), "RETRY_ERROR", failureDetail, now);
            log.warn("푸시 재시도 처리 중 예외가 발생했습니다. deliveryId={}, errorType={}, reason={}",
                    delivery.getId(), exception.getClass().getSimpleName(), safeExceptionMessage(exception));
            refreshWeeklyJobIfNeeded(delivery);
        }
    }

    private void refreshWeeklyJobIfNeeded(RetryablePushDeliveryRecord delivery) {
        if (delivery.getWeeklyReportId() != null) {
            mapper.refreshWeeklyNotificationJobDeliveryResult(delivery.getWeeklyReportId());
        }
    }

    private boolean isPermanentTokenFailure(String code, String message) {
        final String normalizedCode = safeErrorCode(code).toUpperCase(Locale.ROOT);
        if ("UNREGISTERED".equals(normalizedCode)
                || "SENDER_ID_MISMATCH".equals(normalizedCode)
                || "REGISTRATION-TOKEN-NOT-REGISTERED".equals(normalizedCode)
                || "MISMATCHED-CREDENTIAL".equals(normalizedCode)) {
            return true;
        }
        // INVALID_ARGUMENT is terminal only when Firebase explicitly identifies the registration token.
        return "INVALID_ARGUMENT".equals(normalizedCode)
                && safeErrorMessage(message).toLowerCase(Locale.ROOT).contains("token");
    }

    private String safeErrorCode(String value) {
        return value == null || value.isBlank() ? "UNKNOWN" : value.trim();
    }

    private String safeErrorMessage(String value) {
        if (value == null || value.isBlank()) {
            return "Firebase에서 실패 사유를 반환하지 않았습니다.";
        }
        return value.replaceAll("\\s+", " ").trim().substring(0, Math.min(value.replaceAll("\\s+", " ").trim().length(), 500));
    }

    private String safeExceptionMessage(Exception exception) {
        final String message = exception.getMessage();
        if (message == null || message.isBlank()) {
            return "상세 사유가 없습니다.";
        }
        final String normalized = message.replaceAll("\\s+", " ").trim();
        return normalized.substring(0, Math.min(normalized.length(), 300));
    }
}
