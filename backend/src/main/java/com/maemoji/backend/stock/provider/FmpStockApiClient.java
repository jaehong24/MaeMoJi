package com.maemoji.backend.stock.provider;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.domain.StockMasterItem;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@Component
public class FmpStockApiClient implements StockApiClient {

    private static final String BASE_URL = "https://financialmodelingprep.com/stable";
    private static final Set<String> US_EXCHANGES = Set.of(
            "NASDAQ",
            "NYSE",
            "NYSE_AMERICAN",
            "NYSE_ARCA",
            "BATS"
    );

    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public FmpStockApiClient(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @Override
    public String providerName() {
        return "FMP";
    }

    @Override
    public boolean isAvailable() {
        final String apiKey = System.getenv("FMP_API_KEY");
        return apiKey != null && !apiKey.isBlank();
    }

    @Override
    public List<StockMasterItem> fetchUsStocksAndEtfs() {
        final String apiKey = System.getenv("FMP_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("FMP_API_KEY 환경변수가 설정되지 않았습니다.");
        }

        final Map<String, StockMasterItem> itemsBySymbol = new LinkedHashMap<>();
        parseItems(fetch("/stock-list", apiKey), false).forEach(
                item -> itemsBySymbol.put(item.symbol(), item)
        );
        parseItems(fetch("/etf-list", apiKey), true).forEach(
                item -> itemsBySymbol.put(item.symbol(), item)
        );
        return List.copyOf(itemsBySymbol.values());
    }

    List<StockMasterItem> parseItems(String json, boolean forceEtf) {
        try {
            final JsonNode root = objectMapper.readTree(json);
            if (!root.isArray()) {
                throw new IllegalStateException("FMP 종목 목록 응답 형식이 올바르지 않습니다.");
            }

            final List<StockMasterItem> items = new ArrayList<>();
            for (JsonNode node : root) {
                final String symbol = text(node, "symbol").toUpperCase(Locale.ROOT);
                final String name = firstText(node, "name", "companyName");
                final String exchange = normalizeExchange(
                        firstText(node, "exchangeShortName", "exchange")
                );
                final String type = firstText(node, "type", "assetType");
                if (!isEligible(symbol, name, exchange, type, forceEtf)) {
                    continue;
                }

                items.add(new StockMasterItem(
                        symbol,
                        name,
                        exchange,
                        forceEtf || type.toUpperCase(Locale.ROOT).contains("ETF")
                                ? "ETF"
                                : "STOCK",
                        firstNonBlank(text(node, "currency"), "USD"),
                        "US",
                        nullableText(node, "sector"),
                        nullableText(node, "industry"),
                        nullableText(node, "image")
                ));
            }
            return items;
        } catch (Exception exception) {
            throw new IllegalStateException("FMP 종목 목록 파싱에 실패했습니다.", exception);
        }
    }

    private String fetch(String path, String apiKey) {
        try {
            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + path))
                    .header("apikey", apiKey)
                    .timeout(Duration.ofSeconds(60))
                    .GET()
                    .build();
            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );
            if (response.statusCode() != 200 || response.body().isBlank()) {
                throw new IllegalStateException("FMP 응답 오류: status=" + response.statusCode());
            }
            return response.body();
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("FMP 종목 목록 요청이 중단되었습니다.", exception);
        } catch (Exception exception) {
            throw new IllegalStateException("FMP 종목 목록 요청에 실패했습니다.", exception);
        }
    }

    private boolean isEligible(
            String symbol,
            String name,
            String exchange,
            String type,
            boolean forceEtf
    ) {
        if (symbol.isBlank() || name.isBlank() || !US_EXCHANGES.contains(exchange)) {
            return false;
        }
        if (!symbol.matches("[A-Z0-9.\\-]+")) {
            return false;
        }
        final String upperName = name.toUpperCase(Locale.ROOT);
        if (upperName.contains(" WARRANT")
                || upperName.contains(" RIGHT")
                || upperName.contains(" UNIT")
                || upperName.contains(" TEST ")) {
            return false;
        }
        if (forceEtf) {
            return true;
        }
        final String upperType = type.toUpperCase(Locale.ROOT);
        return upperType.isBlank()
                || upperType.contains("STOCK")
                || upperType.contains("TRUST")
                || upperType.contains("FUND")
                || upperType.contains("ETF");
    }

    private String normalizeExchange(String raw) {
        final String upper = raw.toUpperCase(Locale.ROOT);
        if (upper.contains("NASDAQ")) {
            return "NASDAQ";
        }
        if (upper.contains("ARCA")) {
            return "NYSE_ARCA";
        }
        if (upper.contains("AMEX") || upper.contains("AMERICAN")) {
            return "NYSE_AMERICAN";
        }
        if (upper.contains("NYSE")) {
            return "NYSE";
        }
        if (upper.contains("BATS") || upper.contains("CBOE")) {
            return "BATS";
        }
        return upper;
    }

    private String firstText(JsonNode node, String... names) {
        for (String name : names) {
            final String value = text(node, name);
            if (!value.isBlank()) {
                return value;
            }
        }
        return "";
    }

    private String text(JsonNode node, String name) {
        return node.path(name).asText("").trim();
    }

    private String nullableText(JsonNode node, String name) {
        final String value = text(node, name);
        return value.isBlank() ? null : value;
    }

    private String firstNonBlank(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}
