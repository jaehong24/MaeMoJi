package com.maemoji.backend.health;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 100)
public class ServiceReadinessRunner implements ApplicationRunner {

    private final ServiceReadiness serviceReadiness;

    public ServiceReadinessRunner(ServiceReadiness serviceReadiness) {
        this.serviceReadiness = serviceReadiness;
    }

    @Override
    public void run(ApplicationArguments args) {
        serviceReadiness.markReady();
    }
}
