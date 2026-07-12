package com.maemoji.backend.toss.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Component
public class TossOpenApiClient {

    private static final String BASE_URL = "https://openapi.tossinvest.com";

    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public TossOpenApiClient(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    public TossIssuedToken issueAccessToken(String clientId, String clientSecret) {
        try {
            final String form = "grant_type=client_credentials"
                    + "&client_id=" + encode(clientId)
                    + "&client_secret=" + encode(clientSecret);
            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + "/oauth2/token"))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .timeout(Duration.ofSeconds(20))
                    .POST(HttpRequest.BodyPublishers.ofString(form, StandardCharsets.UTF_8))
                    .build();

            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );

            if (response.statusCode() == 200) {
                final JsonNode body = objectMapper.readTree(response.body());
                final String accessToken = text(body, "access_token");
                final long expiresIn = body.path("expires_in").asLong(0);
                if (accessToken.isBlank()) {
                    throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "토스 토큰 응답에 access_token이 없습니다.");
                }
                return new TossIssuedToken(accessToken, expiresIn);
            }

            throw toRemoteException("토스 토큰 발급", response.statusCode(), response.body());
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "토스 토큰 발급 요청이 중단되었습니다.", exception);
        } catch (ResponseStatusException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "토스 토큰 발급에 실패했습니다.", exception);
        }
    }

    public List<TossRemoteAccount> getAccounts(String accessToken) {
        final JsonNode payload = getJson("/api/v1/accounts", accessToken, null);
        final JsonNode itemsNode = extractPayload(payload);
        if (!itemsNode.isArray()) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "토스 계좌 응답 형식이 예상과 다릅니다.");
        }

        final List<TossRemoteAccount> accounts = new ArrayList<>();
        for (JsonNode node : itemsNode) {
            final long accountSeq = node.path("accountSeq").asLong(0);
            if (accountSeq <= 0) {
                continue;
            }
            final String accountType = text(node, "accountType");
            final String accountNo = text(node, "accountNo");
            accounts.add(new TossRemoteAccount(accountSeq, accountType, accountNo));
        }
        return accounts;
    }

    public List<TossRemoteHolding> getHoldings(String accessToken, Long accountSeq) {
        final JsonNode payload = getJson("/api/v1/holdings", accessToken, accountSeq);
        final JsonNode overview = extractPayload(payload);
        final JsonNode itemsNode = overview.path("items");
        if (!itemsNode.isArray()) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "토스 보유 종목 응답 형식이 예상과 다릅니다.");
        }

        final List<TossRemoteHolding> holdings = new ArrayList<>();
        for (JsonNode node : itemsNode) {
            final String symbol = text(node, "symbol").toUpperCase(Locale.ROOT);
            if (symbol.isBlank()) {
                continue;
            }
            holdings.add(new TossRemoteHolding(
                    symbol,
                    text(node, "name"),
                    text(node, "marketCountry"),
                    text(node, "currency"),
                    decimal(node.path("quantity")),
                    decimal(node.path("averagePurchasePrice")),
                    decimal(node.path("lastPrice")),
                    decimal(node.path("profitLoss").path("rate")),
                    decimal(node.path("marketValue").path("amount"))
            ));
        }
        return holdings;
    }

    private JsonNode getJson(String path, String accessToken, Long accountSeq) {
        try {
            final HttpRequest.Builder builder = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + path))
                    .header("Authorization", "Bearer " + accessToken)
                    .timeout(Duration.ofSeconds(20))
                    .GET();
            if (accountSeq != null) {
                builder.header("X-Tossinvest-Account", String.valueOf(accountSeq));
            }

            final HttpResponse<String> response = httpClient.send(
                    builder.build(),
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );
            if (response.statusCode() == 200) {
                return objectMapper.readTree(response.body());
            }
            throw toRemoteException("토스 API 호출", response.statusCode(), response.body());
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "토스 API 호출이 중단되었습니다.", exception);
        } catch (ResponseStatusException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "토스 API 호출에 실패했습니다.", exception);
        }
    }

    private ResponseStatusException toRemoteException(String action, int statusCode, String body) {
        if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
            return new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    action + "에 실패했습니다. 토스 Open API 자격정보 또는 권한을 확인해주세요. status=" + statusCode
            );
        }
        return new ResponseStatusException(
                HttpStatus.BAD_GATEWAY,
                action + "에 실패했습니다. status=" + statusCode + ", body=" + abbreviate(body)
        );
    }

    private JsonNode extractPayload(JsonNode root) {
        if (root == null || root.isNull()) {
            return objectMapper.nullNode();
        }
        if (root.has("result")) {
            return root.get("result");
        }
        if (root.has("data")) {
            return root.get("data");
        }
        return root;
    }

    private String text(JsonNode node, String fieldName) {
        return node.path(fieldName).asText("").trim();
    }

    private BigDecimal decimal(JsonNode node) {
        final String raw = node == null ? "" : node.asText("").trim();
        if (raw.isBlank()) {
            return null;
        }
        try {
            return new BigDecimal(raw);
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private String abbreviate(String body) {
        if (body == null) {
            return "";
        }
        final String normalized = body.replaceAll("\\s+", " ").trim();
        return normalized.length() <= 200 ? normalized : normalized.substring(0, 200) + "...";
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    public record TossIssuedToken(String accessToken, long expiresIn) {
    }

    public record TossRemoteAccount(
            long accountSeq,
            String accountType,
            String accountNo
    ) {
    }

    public record TossRemoteHolding(
            String symbol,
            String stockName,
            String marketCountry,
            String currency,
            BigDecimal quantity,
            BigDecimal averagePurchasePrice,
            BigDecimal currentPrice,
            BigDecimal profitRate,
            BigDecimal marketValue
    ) {
    }
}
