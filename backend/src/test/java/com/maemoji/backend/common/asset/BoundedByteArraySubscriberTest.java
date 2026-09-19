package com.maemoji.backend.common.asset;

import org.junit.jupiter.api.Test;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.concurrent.Flow;
import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

class BoundedByteArraySubscriberTest {
    @Test
    void cancelsChunkedOversizedBodyBeforeCopyingIt() {
        final var subscriber = new BoundedByteArraySubscriber(4);
        final var subscription = mock(Flow.Subscription.class);
        subscriber.onSubscribe(subscription);
        subscriber.onNext(List.of(ByteBuffer.wrap(new byte[]{1, 2, 3})));
        subscriber.onNext(List.of(ByteBuffer.wrap(new byte[]{4, 5})));
        verify(subscription).cancel();
        assertThatThrownBy(() -> subscriber.getBody().toCompletableFuture().join())
                .hasCauseInstanceOf(BoundedByteArraySubscriber.BodyTooLargeException.class);
    }

    @Test
    void permitsExactlyLimitAndPropagatesNetworkError() {
        final var subscriber = new BoundedByteArraySubscriber(4);
        subscriber.onSubscribe(mock(Flow.Subscription.class));
        subscriber.onNext(List.of(ByteBuffer.wrap(new byte[]{1, 2}), ByteBuffer.wrap(new byte[]{3, 4})));
        subscriber.onComplete();
        assertThat(subscriber.getBody().toCompletableFuture().join()).containsExactly(1, 2, 3, 4);
        final var failed = new BoundedByteArraySubscriber(4);
        failed.onError(new java.io.IOException("network"));
        assertThatThrownBy(() -> failed.getBody().toCompletableFuture().join())
                .hasCauseInstanceOf(java.io.IOException.class);
    }
}
