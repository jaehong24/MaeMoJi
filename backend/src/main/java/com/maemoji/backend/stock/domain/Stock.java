package com.maemoji.backend.stock.domain;

import java.time.OffsetDateTime;

public class Stock {
    private Long id;
    private String symbol;
    private String ticker;
    private String exchange;
    private String exchangeCode;
    private String finnhubSymbol;
    private String nameKo;
    private String nameEn;
    private String tickerNormalized;
    private String nameKoNormalized;
    private String nameEnNormalized;
    private String searchText;
    private String logoUrl;
    private String logoStatus;
    private OffsetDateTime logoCheckedAt;
    private String marketType;
    private String assetType;
    private String currency;
    private String country;
    private String sector;
    private String industry;
    private Boolean isActive;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public String getTicker() {
        return ticker;
    }

    public void setTicker(String ticker) {
        this.ticker = ticker;
    }

    public String getExchange() {
        return exchange;
    }

    public void setExchange(String exchange) {
        this.exchange = exchange;
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

    public String getLogoStatus() {
        return logoStatus;
    }

    public void setLogoStatus(String logoStatus) {
        this.logoStatus = logoStatus;
    }

    public OffsetDateTime getLogoCheckedAt() {
        return logoCheckedAt;
    }

    public void setLogoCheckedAt(OffsetDateTime logoCheckedAt) {
        this.logoCheckedAt = logoCheckedAt;
    }

    public String getMarketType() {
        return marketType;
    }

    public void setMarketType(String marketType) {
        this.marketType = marketType;
    }

    public String getAssetType() {
        return assetType;
    }

    public void setAssetType(String assetType) {
        this.assetType = assetType;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
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
