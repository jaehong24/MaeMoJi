package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.common.startup.PushNotificationSchemaInitializer;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.anyString;

class PushSchemaReadinessTest {
    @Test
    void becomesReadyOnlyAfterSuccessfulInitialization() {
        var jdbc = mock(JdbcTemplate.class);
        var initializer = new PushNotificationSchemaInitializer(jdbc);
        assertThat(initializer.isReady()).isFalse();
        initializer.run(null);
        assertThat(initializer.isReady()).isTrue();
    }

    @Test
    void remainsUnreadyWhenMigrationFails() {
        var jdbc = mock(JdbcTemplate.class);
        doThrow(new IllegalStateException("migration failed")).when(jdbc).execute(anyString());
        var initializer = new PushNotificationSchemaInitializer(jdbc);
        assertThatThrownBy(() -> initializer.run(null)).isInstanceOf(IllegalStateException.class);
        assertThat(initializer.isReady()).isFalse();
    }
}
