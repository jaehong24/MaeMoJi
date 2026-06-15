package com.maemoji.backend.stock.provider;

public interface StockLogoProvider {

    String logoUrl(String symbol);

    StockLogoAvailability checkLogo(String symbol);
}
