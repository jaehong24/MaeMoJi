package com.maemoji.backend.market.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.market.dto.ExchangeRateResponse;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

@Service
public class ExchangeRateService {

    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public ExchangeRateService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    /// USD/KRW 표시에 사용할 환율을 조회합니다.
    public ExchangeRateResponse fetchUsdKrwRate() {
        try {
            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.frankfurter.dev/v2/rate/USD/KRW"))
                    .timeout(Duration.ofSeconds(15))
                    .GET()
                    .build();

            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );

            if (response.statusCode() != 200 || response.body().isBlank()) {
                throw new IllegalStateException(
                        "환율 API 응답이 비정상입니다. status=" + response.statusCode()
                );
            }

            final JsonNode body = objectMapper.readTree(response.body());
            final Double rate = extractRate(body);

            if (rate == null || rate <= 0) {
                throw new IllegalStateException("USD/KRW 환율 값을 찾지 못했습니다.");
            }

            return new ExchangeRateResponse("USD", "KRW", rate);
        } catch (Exception exception) {
            throw new IllegalStateException("USD/KRW 환율 조회에 실패했습니다.", exception);
        }
    }

    private Double extractRate(JsonNode body) {
        if (body == null || body.isNull()) {
            return null;
        }

        if (body.isNumber()) {
            return body.asDouble();
        }

        if (body.isObject()) {
            if (body.has("rate") && body.get("rate").isNumber()) {
                return body.get("rate").asDouble();
            }

            if (body.has("rates") && body.get("rates").has("KRW")) {
                final JsonNode krwNode = body.get("rates").get("KRW");
                if (krwNode.isNumber()) {
                    return krwNode.asDouble();
                }
            }
        }

        if (body.isArray() && !body.isEmpty()) {
            return extractRate(body.get(0));
        }

        return null;
    }
}
