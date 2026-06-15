package com.maemoji.backend.stock.provider;

import com.maemoji.backend.stock.domain.StockMasterItem;

import java.util.List;

public interface StockApiClient {

    String providerName();

    boolean isAvailable();

    List<StockMasterItem> fetchUsStocksAndEtfs();
}
