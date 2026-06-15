package com.maemoji.backend.stock.provider;

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

@Component
public class NasdaqStockApiClient implements StockApiClient {

    private static final String NASDAQ_URL =
            "https://www.nasdaqtrader.com/dynamic/SymDir/nasdaqlisted.txt";
    private static final String OTHER_URL =
            "https://www.nasdaqtrader.com/dynamic/SymDir/otherlisted.txt";

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    @Override
    public String providerName() {
        return "NASDAQ_SYMBOL_DIRECTORY";
    }

    @Override
    public boolean isAvailable() {
        return true;
    }

    @Override
    public List<StockMasterItem> fetchUsStocksAndEtfs() {
        final Map<String, StockMasterItem> itemsBySymbol = new LinkedHashMap<>();
        parseNasdaqListed(fetch(NASDAQ_URL)).forEach(
                item -> itemsBySymbol.put(item.symbol(), item)
        );
        parseOtherListed(fetch(OTHER_URL)).forEach(
                item -> itemsBySymbol.put(item.symbol(), item)
        );
        return List.copyOf(itemsBySymbol.values());
    }

    List<StockMasterItem> parseNasdaqListed(String content) {
        return parse(content, true);
    }

    List<StockMasterItem> parseOtherListed(String content) {
        return parse(content, false);
    }

    private List<StockMasterItem> parse(String content, boolean nasdaqListed) {
        final List<StockMasterItem> items = new ArrayList<>();
        final String[] lines = content.split("\\R");
        if (lines.length < 2) {
            return items;
        }

        final Map<String, Integer> columns = headerColumns(lines[0]);
        for (int index = 1; index < lines.length; index++) {
            final String line = lines[index].trim();
            if (line.isEmpty() || line.startsWith("File Creation Time")) {
                continue;
            }

            final String[] values = line.split("\\|", -1);
            final String symbol = value(
                    values,
                    columns,
                    nasdaqListed ? "Symbol" : "ACT Symbol"
            ).toUpperCase(Locale.ROOT);
            final String name = value(values, columns, "Security Name");
            final String testIssue = value(values, columns, "Test Issue");
            final boolean etf = "Y".equalsIgnoreCase(value(values, columns, "ETF"));

            if (!"N".equalsIgnoreCase(testIssue)
                    || !isEligibleSecurity(symbol, name)) {
                continue;
            }

            final String exchange = nasdaqListed
                    ? "NASDAQ"
                    : normalizeOtherExchange(value(values, columns, "Exchange"));
            if (exchange.isBlank()) {
                continue;
            }

            items.add(new StockMasterItem(
                    symbol,
                    name.trim(),
                    exchange,
                    etf ? "ETF" : "STOCK",
                    "USD",
                    "US",
                    null,
                    null,
                    null
            ));
        }
        return items;
    }

    private String fetch(String url) {
        try {
            final HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(60))
                    .GET()
                    .build();
            final HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );
            if (response.statusCode() != 200 || response.body().isBlank()) {
                throw new IllegalStateException(
                        "Nasdaq Symbol Directory 응답 오류: status=" + response.statusCode()
                );
            }
            return response.body();
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Nasdaq 종목 목록 요청이 중단되었습니다.", exception);
        } catch (Exception exception) {
            throw new IllegalStateException("Nasdaq 종목 목록 요청에 실패했습니다.", exception);
        }
    }

    private Map<String, Integer> headerColumns(String header) {
        final String[] names = header.replace("\uFEFF", "").split("\\|", -1);
        final Map<String, Integer> columns = new LinkedHashMap<>();
        for (int index = 0; index < names.length; index++) {
            columns.put(names[index].trim(), index);
        }
        return columns;
    }

    private String value(String[] values, Map<String, Integer> columns, String name) {
        final Integer index = columns.get(name);
        if (index == null || index >= values.length) {
            return "";
        }
        return values[index].trim();
    }

    private String normalizeOtherExchange(String code) {
        return switch (code.toUpperCase(Locale.ROOT)) {
            case "N" -> "NYSE";
            case "A" -> "NYSE_AMERICAN";
            case "P" -> "NYSE_ARCA";
            case "Z" -> "BATS";
            case "V" -> "IEX";
            default -> "";
        };
    }

    private boolean isEligibleSecurity(String symbol, String name) {
        if (symbol.isBlank()
                || name.isBlank()
                || !symbol.matches("[A-Z0-9.\\-]+")) {
            return false;
        }
        final String upperName = " " + name.toUpperCase(Locale.ROOT) + " ";
        return !upperName.contains(" WARRANT")
                && !upperName.contains(" RIGHTS")
                && !upperName.contains(" RIGHT ")
                && !upperName.contains(" UNITS")
                && !upperName.contains(" UNIT ")
                && !upperName.contains(" TEST ")
                && !upperName.contains(" NEXTSHARES");
    }
}
