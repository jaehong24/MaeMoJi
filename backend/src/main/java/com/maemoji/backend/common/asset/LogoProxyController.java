package com.maemoji.backend.common.asset;

import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.net.URL;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Locale;
import java.util.Set;

@RestController
@RequestMapping("/api/assets")
public class LogoProxyController {

    private static final Set<String> ALLOWED_HOSTS = Set.of(
            "static2.finnhub.io",
            "finnhub.io"
    );

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    @GetMapping("/logo-proxy")
    public ResponseEntity<byte[]> proxyLogo(@RequestParam("url") String url) throws Exception {
        final String trimmed = url == null ? "" : url.trim();
        if (trimmed.isBlank()) {
            return ResponseEntity.badRequest().body(new byte[0]);
        }

        final URI sourceUri = URI.create(trimmed);
        final String host = sourceUri.getHost() == null ? "" : sourceUri.getHost().toLowerCase(Locale.ROOT);
        if (!ALLOWED_HOSTS.contains(host)) {
            return ResponseEntity.badRequest().body(new byte[0]);
        }

        final HttpRequest request = HttpRequest.newBuilder()
                .uri(sourceUri)
                .timeout(Duration.ofSeconds(15))
                .GET()
                .build();

        final HttpResponse<byte[]> response = httpClient.send(
                request,
                HttpResponse.BodyHandlers.ofByteArray()
        );

        if (response.statusCode() != 200 || response.body() == null || response.body().length == 0) {
            return ResponseEntity.status(502).body(new byte[0]);
        }

        final String contentType = response.headers()
                .firstValue("content-type")
                .orElse(MediaType.IMAGE_PNG_VALUE);

        return ResponseEntity.ok()
                .header(HttpHeaders.CACHE_CONTROL, CacheControl.maxAge(Duration.ofDays(7)).cachePublic().getHeaderValue())
                .contentType(MediaType.parseMediaType(contentType))
                .body(response.body());
    }
}
