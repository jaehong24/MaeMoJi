package com.maemoji.backend.health;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class HealthControllerTest {

    private final ServiceReadiness serviceReadiness = mock(ServiceReadiness.class);
    private final JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
    private final HealthController controller = new HealthController(serviceReadiness, jdbcTemplate);

    @Test
    void readinessReportsUpOnlyWhenTheDatabaseAnswers() {
        when(serviceReadiness.isReady()).thenReturn(true);
        when(jdbcTemplate.queryForObject("select 1", Integer.class)).thenReturn(1);

        final var response = controller.readiness();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("UP", response.getBody().data().get("database"));
    }

    @Test
    void readinessReportsDatabaseFailureWithoutChangingLiveness() {
        when(serviceReadiness.isReady()).thenReturn(true);
        when(jdbcTemplate.queryForObject("select 1", Integer.class))
                .thenThrow(new IllegalStateException("connection failed"));

        final var readiness = controller.readiness();
        final var liveness = controller.health();

        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, readiness.getStatusCode());
        assertEquals("DOWN", readiness.getBody().data().get("database"));
        assertEquals(HttpStatus.OK, liveness.getStatusCode());
        assertTrue(liveness.getBody().success());
    }
}
