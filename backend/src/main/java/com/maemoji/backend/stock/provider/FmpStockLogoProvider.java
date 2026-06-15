package com.maemoji.backend.stock.provider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Locale;

@Component
public class FmpStockLogoProvider implements StockLogoProvider {

    private static final Logger log =
            LoggerFactory.getLogger(FmpStockLogoProvider.class);
    private static final String BASE_URL =
            "https://financialmodelingprep.com/image-stock/";

    private final HttpClient httpClient;

    public FmpStockLogoProvider() {
        this(HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .followRedirects(HttpClient.Redirect.NORMAL)
                .build());
    }

    FmpStockLogoProvider(HttpClient httpClient) {
        this.httpClient = httpClient;
    }

    @Override
    public String logoUrl(String symbol) {
        final String normalized = normalizeSymbol(symbol);
        return BASE_URL
                + URLEncoder.encode(normalized, StandardCharsets.UTF_8)
                + ".png";
    }

    @Override
    public StockLogoAvailability checkLogo(String symbol) {
        final HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(logoUrl(symbol)))
                .timeout(Duration.ofSeconds(8))
                .header("User-Agent", "MaeMoJi/1.0")
                .GET()
                .build();

        try {
            final HttpResponse<Void> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.discarding()
            );
            final String contentType = response.headers()
                    .firstValue("content-type")
                    .orElse("");
            if (response.statusCode() == 200
                    && contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {
                return StockLogoAvailability.AVAILABLE;
            }
            if (response.statusCode() == 404) {
                return StockLogoAvailability.MISSING;
            }
            return StockLogoAvailability.RETRY;
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            return StockLogoAvailability.RETRY;
        } catch (Exception exception) {
            log.warn(
                    "FMP 종목 로고 확인에 실패했습니다. symbol={}, reason={}",
                    symbol,
                    exception.getMessage()
            );
            return StockLogoAvailability.RETRY;
        }
    }

    private String normalizeSymbol(String symbol) {
        if (symbol == null || symbol.isBlank()) {
            throw new IllegalArgumentException("종목 심볼이 비어 있습니다.");
        }
        return symbol.trim().toUpperCase(Locale.ROOT);
    }
}
