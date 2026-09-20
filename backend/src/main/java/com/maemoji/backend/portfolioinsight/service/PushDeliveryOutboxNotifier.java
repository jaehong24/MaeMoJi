package com.maemoji.backend.portfolioinsight.service;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@Component
public class PushDeliveryOutboxNotifier {

    private final ApplicationEventPublisher eventPublisher;

    public PushDeliveryOutboxNotifier(ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
    }

    public void requestDispatchAfterCommit() {
        if (TransactionSynchronizationManager.isSynchronizationActive()
                && TransactionSynchronizationManager.isActualTransactionActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    eventPublisher.publishEvent(new PushDeliveryQueuedEvent());
                }
            });
            return;
        }
        eventPublisher.publishEvent(new PushDeliveryQueuedEvent());
    }
}
