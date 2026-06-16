package com.maemoji.backend.stock.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

public class StockPriceSnapshotRecord {
    private Long stockId;
    private LocalDate snapshotDate;
    private BigDecimal currentPrice;
    private BigDecimal changeRate1d;
    private BigDecimal changeRate7d;
    private BigDecimal changeRate30d;
    private BigDecimal marketCap;
    private BigDecimal perValue;
    private BigDecimal epsTtm;
    private BigDecimal revenueGrowthYoy;
    private BigDecimal operatingMarginTtm;
    private BigDecimal roeTtm;
    private BigDecimal debtToEquityTtm;
    private String source;

    public Long getStockId() {
        return stockId;
    }

    public void setStockId(Long stockId) {
        this.stockId = stockId;
    }

    public LocalDate getSnapshotDate() {
        return snapshotDate;
    }

    public void setSnapshotDate(LocalDate snapshotDate) {
        this.snapshotDate = snapshotDate;
    }

    public BigDecimal getCurrentPrice() {
        return currentPrice;
    }

    public void setCurrentPrice(BigDecimal currentPrice) {
        this.currentPrice = currentPrice;
    }

    public BigDecimal getChangeRate1d() {
        return changeRate1d;
    }

    public void setChangeRate1d(BigDecimal changeRate1d) {
        this.changeRate1d = changeRate1d;
    }

    public BigDecimal getChangeRate7d() {
        return changeRate7d;
    }

    public void setChangeRate7d(BigDecimal changeRate7d) {
        this.changeRate7d = changeRate7d;
    }

    public BigDecimal getChangeRate30d() {
        return changeRate30d;
    }

    public void setChangeRate30d(BigDecimal changeRate30d) {
        this.changeRate30d = changeRate30d;
    }

    public BigDecimal getMarketCap() {
        return marketCap;
    }

    public void setMarketCap(BigDecimal marketCap) {
        this.marketCap = marketCap;
    }

    public BigDecimal getPerValue() {
        return perValue;
    }

    public void setPerValue(BigDecimal perValue) {
        this.perValue = perValue;
    }

    public BigDecimal getEpsTtm() {
        return epsTtm;
    }

    public void setEpsTtm(BigDecimal epsTtm) {
        this.epsTtm = epsTtm;
    }

    public BigDecimal getRevenueGrowthYoy() {
        return revenueGrowthYoy;
    }

    public void setRevenueGrowthYoy(BigDecimal revenueGrowthYoy) {
        this.revenueGrowthYoy = revenueGrowthYoy;
    }

    public BigDecimal getOperatingMarginTtm() {
        return operatingMarginTtm;
    }

    public void setOperatingMarginTtm(BigDecimal operatingMarginTtm) {
        this.operatingMarginTtm = operatingMarginTtm;
    }

    public BigDecimal getRoeTtm() {
        return roeTtm;
    }

    public void setRoeTtm(BigDecimal roeTtm) {
        this.roeTtm = roeTtm;
    }

    public BigDecimal getDebtToEquityTtm() {
        return debtToEquityTtm;
    }

    public void setDebtToEquityTtm(BigDecimal debtToEquityTtm) {
        this.debtToEquityTtm = debtToEquityTtm;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }
}
