package com.maemoji.backend.stock.domain;

import java.time.OffsetDateTime;

public class Stock {
    private Long id;
    private String ticker;
    private String exchangeCode;
    private String finnhubSymbol;
    private String nameKo;
    private String nameEn;
    private String tickerNormalized;
    private String nameKoNormalized;
    private String nameEnNormalized;
    private String searchText;
    private String logoUrl;
    private String marketType;
    private Boolean isActive;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTicker() {
        return ticker;
    }

    public void setTicker(String ticker) {
        this.ticker = ticker;
    }

    public String getExchangeCode() {
        return exchangeCode;
    }

    public void setExchangeCode(String exchangeCode) {
        this.exchangeCode = exchangeCode;
    }

    public String getFinnhubSymbol() {
        return finnhubSymbol;
    }

    public void setFinnhubSymbol(String finnhubSymbol) {
        this.finnhubSymbol = finnhubSymbol;
    }

    public String getNameKo() {
        return nameKo;
    }

    public void setNameKo(String nameKo) {
        this.nameKo = nameKo;
    }

    public String getNameEn() {
        return nameEn;
    }

    public void setNameEn(String nameEn) {
        this.nameEn = nameEn;
    }

    public String getTickerNormalized() {
        return tickerNormalized;
    }

    public void setTickerNormalized(String tickerNormalized) {
        this.tickerNormalized = tickerNormalized;
    }

    public String getNameKoNormalized() {
        return nameKoNormalized;
    }

    public void setNameKoNormalized(String nameKoNormalized) {
        this.nameKoNormalized = nameKoNormalized;
    }

    public String getNameEnNormalized() {
        return nameEnNormalized;
    }

    public void setNameEnNormalized(String nameEnNormalized) {
        this.nameEnNormalized = nameEnNormalized;
    }

    public String getSearchText() {
        return searchText;
    }

    public void setSearchText(String searchText) {
        this.searchText = searchText;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public String getMarketType() {
        return marketType;
    }

    public void setMarketType(String marketType) {
        this.marketType = marketType;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean active) {
        isActive = active;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(OffsetDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
