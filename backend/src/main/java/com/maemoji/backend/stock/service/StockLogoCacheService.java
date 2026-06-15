package com.maemoji.backend.stock.service;

import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.mapper.StockMapper;
import com.maemoji.backend.stock.provider.StockLogoAvailability;
import com.maemoji.backend.stock.provider.StockLogoProvider;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class StockLogoCacheService {

    private static final String AVAILABLE = "AVAILABLE";
    private static final String MISSING = "MISSING";
    private static final Duration MISSING_RETRY_INTERVAL = Duration.ofDays(30);

    private final StockMapper stockMapper;
    private final StockLogoProvider stockLogoProvider;
    private final Set<Long> inProgress = ConcurrentHashMap.newKeySet();

    public StockLogoCacheService(
            StockMapper stockMapper,
            StockLogoProvider stockLogoProvider
    ) {
        this.stockMapper = stockMapper;
        this.stockLogoProvider = stockLogoProvider;
    }

    public String resolveDisplayLogoUrl(Stock stock) {
        if (hasText(stock.getLogoUrl())) {
            return stock.getLogoUrl();
        }
        if (!shouldCheck(stock)) {
            return null;
        }
        return stockLogoProvider.logoUrl(resolveSymbol(stock));
    }

    @Async("stockLogoExecutor")
    public void cacheMissingLogos(List<Stock> stocks) {
        stocks.stream()
                .filter(this::shouldCheck)
                .limit(10)
                .forEach(this::cacheLogo);
    }

    private void cacheLogo(Stock stock) {
        if (stock.getId() == null || !inProgress.add(stock.getId())) {
            return;
        }

        try {
            final String symbol = resolveSymbol(stock);
            final StockLogoAvailability availability =
                    stockLogoProvider.checkLogo(symbol);
            if (availability == StockLogoAvailability.RETRY) {
                return;
            }
            final boolean exists =
                    availability == StockLogoAvailability.AVAILABLE;
            stockMapper.updateStockLogoCache(
                    stock.getId(),
                    exists ? stockLogoProvider.logoUrl(symbol) : null,
                    exists ? AVAILABLE : MISSING,
                    OffsetDateTime.now()
            );
        } finally {
            inProgress.remove(stock.getId());
        }
    }

    private boolean shouldCheck(Stock stock) {
        if (stock == null || stock.getId() == null || hasText(stock.getLogoUrl())) {
            return false;
        }
        if (!MISSING.equals(stock.getLogoStatus())) {
            return true;
        }
        return stock.getLogoCheckedAt() == null
                || stock.getLogoCheckedAt()
                .isBefore(OffsetDateTime.now().minus(MISSING_RETRY_INTERVAL));
    }

    private String resolveSymbol(Stock stock) {
        return hasText(stock.getSymbol()) ? stock.getSymbol() : stock.getTicker();
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
