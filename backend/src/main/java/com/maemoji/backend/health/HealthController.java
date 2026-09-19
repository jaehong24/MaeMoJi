package com.maemoji.backend.health;

import com.maemoji.backend.common.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HealthController {

    private final ServiceReadiness serviceReadiness;
    private final JdbcTemplate jdbcTemplate;

    public HealthController(ServiceReadiness serviceReadiness, JdbcTemplate jdbcTemplate) {
        this.serviceReadiness = serviceReadiness;
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping({"/", "/api/health"})
    public ResponseEntity<ApiResponse<Map<String, String>>> health() {
        if (!serviceReadiness.isReady()) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(
                    new ApiResponse<>(
                            false,
                            Map.of(
                                    "service", "maemoji-backend",
                                    "status", "STARTING"
                            ),
                            "서비스 준비 중"
                    )
            );
        }

        return ResponseEntity.ok(ApiResponse.ok(Map.of(
                "service", "maemoji-backend",
                "status", "UP"
        )));
    }

    /**
     * Readiness is intentionally separate from the Render liveness endpoint so a database
     * outage is visible without causing the platform to restart an otherwise healthy JVM.
     */
    @GetMapping("/api/health/ready")
    public ResponseEntity<ApiResponse<Map<String, String>>> readiness() {
        if (!serviceReadiness.isReady()) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(
                    new ApiResponse<>(
                            false,
                            Map.of("service", "maemoji-backend", "status", "STARTING"),
                            "서비스 준비 중"
                    )
            );
        }

        try {
            final Integer databaseResult = jdbcTemplate.queryForObject("select 1", Integer.class);
            if (databaseResult == null || databaseResult != 1) {
                throw new IllegalStateException("database readiness query returned an unexpected value");
            }
            return ResponseEntity.ok(ApiResponse.ok(Map.of(
                    "service", "maemoji-backend",
                    "status", "UP",
                    "database", "UP"
            )));
        } catch (Exception exception) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(
                    new ApiResponse<>(
                            false,
                            Map.of(
                                    "service", "maemoji-backend",
                                    "status", "DEGRADED",
                                    "database", "DOWN"
                            ),
                            "데이터베이스 연결을 확인할 수 없습니다."
                    )
            );
        }
    }
}
