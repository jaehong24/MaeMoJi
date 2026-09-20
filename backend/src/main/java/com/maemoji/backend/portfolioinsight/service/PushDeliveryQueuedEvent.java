package com.maemoji.backend.portfolioinsight.service;

/** Marks that newly committed push deliveries are ready for the shared outbox worker. */
public record PushDeliveryQueuedEvent() {
}
