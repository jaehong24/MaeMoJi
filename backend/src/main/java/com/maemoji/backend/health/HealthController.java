package com.maemoji.backend.health;

import com.maemoji.backend.common.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    private final ServiceReadiness serviceReadiness;

    public HealthController(ServiceReadiness serviceReadiness) {
        this.serviceReadiness = serviceReadiness;
    }

    @GetMapping
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
}
