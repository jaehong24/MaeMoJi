package com.maemoji.backend.stock.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.dto.StockQuoteResponse;
import com.maemoji.backend.stock.mapper.StockMapper;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class StockQuoteService {

    private static final TypeReference<Map<String, Object>> MAP_TYPE =
            new TypeReference<>() {
            };
    private static final Duration QUOTE_CACHE_TTL = Duration.ofSeconds(60);

    private final StockMapper stockMapper;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;
    private final Map<Long, CachedQuote> quoteCache = new ConcurrentHashMap<>();

    public StockQuoteService(
            StockMapper stockMapper,
            ObjectMapper objectMapper
    ) {
        this.stockMapper = stockMapper;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    /// 종목 등록 화면에서 보여줄 현재가를 우리 WAS를 통해 조회합니다.
    public StockQuoteResponse fetchQuote(Long stockId) {
        final CachedQuote cachedQuote = quoteCache.get(stockId);
        if (cachedQuote != null && cachedQuote.expiresAt().isAfter(Instant.now())) {
            return cachedQuote.quote();
        }

        final Stock stock = stockMapper.findStockById(stockId);

        if (stock == null) {
            throw new IllegalArgumentException("존재하지 않는 종목입니다. stockId=" + stockId);
        }

        final String apiKey = System.getenv("FINNHUB_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("FINNHUB_API_KEY 환경변수가 필요합니다.");
        }

        final String symbol = stock.getFinnhubSymbol() == null || stock.getFinnhubSymbol().isBlank()
                ? stock.getTicker()
                : stock.getFinnhubSymbol();
        final Map<String, Object> quote = fetchFinnhubQuote(symbol, apiKey);

        final StockQuoteResponse result = new StockQuoteResponse(
                stock.getId(),
                symbol,
                toDouble(quote.get("c")),
                toDouble(quote.get("d")),
                toDouble(quote.get("dp")),
                toDouble(quote.get("pc")),
                toLong(quote.get("t"))
        );
        quoteCache.put(
                stockId,
                new CachedQuote(result, Instant.now().plus(QUOTE_CACHE_TTL))
        );
        return result;
    }

    private Map<String, Object> fetchFinnhubQuote(String symbol, String apiKey) {
        try {
            final String uri = "https://finnhub.io/api/v1/quote?symbol="
                    + encode(symbol)
                    + "&token="
                    + encode(apiKey);

            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .timeout(Duration.ofSeconds(15))
                    .GET()
                    .build();

            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );

            if (response.statusCode() != 200 || response.body().isBlank()) {
                throw new IllegalStateException("Finnhub quote 응답이 비정상입니다. status=" + response.statusCode());
            }

            return objectMapper.readValue(response.body(), MAP_TYPE);
        } catch (Exception exception) {
            throw new IllegalStateException("종목 현재가 조회에 실패했습니다.", exception);
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private double toDouble(Object value) {
        if (value instanceof Number number) {
            return number.doubleValue();
        }

        if (value == null) {
            return 0;
        }

        try {
            return Double.parseDouble(value.toString());
        } catch (NumberFormatException exception) {
            return 0;
        }
    }

    private Long toLong(Object value) {
        if (value instanceof Number number) {
            return number.longValue();
        }

        if (value == null) {
            return null;
        }

        try {
            return Long.parseLong(value.toString());
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private record CachedQuote(StockQuoteResponse quote, Instant expiresAt) {
    }
}
