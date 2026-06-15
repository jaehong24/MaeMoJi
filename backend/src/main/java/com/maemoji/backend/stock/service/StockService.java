package com.maemoji.backend.stock.service;

import com.maemoji.backend.stock.dto.StockSummaryResponse;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.mapper.StockMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

@Service
public class StockService {

    private final StockMapper stockMapper;
    private final StockLogoCacheService stockLogoCacheService;

    public StockService(
            StockMapper stockMapper,
            StockLogoCacheService stockLogoCacheService
    ) {
        this.stockMapper = stockMapper;
        this.stockLogoCacheService = stockLogoCacheService;
    }

    public List<StockSummaryResponse> searchStocks(String keyword) {
        final String normalizedKeyword = keyword == null ? "" : keyword.trim();
        if (normalizedKeyword.isEmpty()) {
            return List.of();
        }
        final List<Stock> stocks = stockMapper.searchStocks(normalizedKeyword, 20);
        stockLogoCacheService.cacheMissingLogos(stocks);

        return stocks
                .stream()
                .map(stock -> new StockSummaryResponse(
                        stock.getId(),
                        stock.getSymbol(),
                        stock.getTicker(),
                        stock.getExchange(),
                        stock.getExchangeCode(),
                        stock.getNameKo(),
                        stock.getNameEn(),
                        stockLogoCacheService.resolveDisplayLogoUrl(stock),
                        stock.getAssetType()
                ))
                .toList();
    }

    /// 검색 마스터 테이블에 저장할 정규화 필드를 한 곳에서 계산합니다.
    public NormalizedStockFields normalizeStockFields(
            String ticker,
            String nameKo,
            String nameEn
    ) {
        final String tickerNormalized = normalize(ticker);
        final String nameKoNormalized = normalizeNullable(nameKo);
        final String nameEnNormalized = normalize(nameEn);
        final String searchText = String.join(
                " ",
                tickerNormalized,
                nameEnNormalized,
                nameKoNormalized == null ? "" : nameKoNormalized
        ).trim().replaceAll("\\s+", " ");

        return new NormalizedStockFields(
                tickerNormalized,
                nameKoNormalized,
                nameEnNormalized,
                searchText
        );
    }

    public String resolveDisplayName(Stock stock) {
        return stock.getNameKo() != null && !stock.getNameKo().isBlank()
                ? stock.getNameKo()
                : stock.getNameEn();
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
    }

    private String normalizeNullable(String value) {
        if (value == null) {
            return null;
        }

        final String normalized = value.trim().toLowerCase(Locale.ROOT);
        return normalized.isEmpty() ? null : normalized;
    }

    public record NormalizedStockFields(
            String tickerNormalized,
            String nameKoNormalized,
            String nameEnNormalized,
            String searchText
    ) {
    }
}
