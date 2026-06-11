package com.maemoji.backend.common.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebCorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(
                        "http://localhost:3000",
                        "http://localhost:5000",
                        "http://localhost:8080",
                        "http://localhost:8081",
                        "http://127.0.0.1:3000",
                        "http://127.0.0.1:5000",
                        "http://127.0.0.1:8080",
                        "http://127.0.0.1:8081",
                        "https://maemoji-c4302.web.app",
                        "https://maemoji-c4302.firebaseapp.com"
                )
                .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .exposedHeaders("Authorization")
                .allowCredentials(false)
                .maxAge(3600);
    }
}
