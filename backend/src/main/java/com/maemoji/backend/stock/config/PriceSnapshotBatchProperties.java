package com.maemoji.backend.stock.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "maemoji.batch.price-snapshots")
public class PriceSnapshotBatchProperties {

    private boolean enabled = false;
    private String cron = "0 40 6 * * *";
    private int delayMillis = 1200;
    private int defaultLimit = 500;
    private int etfPriceOnlyLimit = 250;
    private int historyLookbackDays = 45;
    private int recentListingWindowDays = 32;
    private int recentFundamentalListingWindowDays = 90;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getCron() {
        return cron;
    }

    public void setCron(String cron) {
        this.cron = cron;
    }

    public int getDelayMillis() {
        return delayMillis;
    }

    public void setDelayMillis(int delayMillis) {
        this.delayMillis = delayMillis;
    }

    public int getDefaultLimit() {
        return defaultLimit;
    }

    public void setDefaultLimit(int defaultLimit) {
        this.defaultLimit = defaultLimit;
    }

    public int getEtfPriceOnlyLimit() {
        return etfPriceOnlyLimit;
    }

    public void setEtfPriceOnlyLimit(int etfPriceOnlyLimit) {
        this.etfPriceOnlyLimit = etfPriceOnlyLimit;
    }

    public int getHistoryLookbackDays() {
        return historyLookbackDays;
    }

    public void setHistoryLookbackDays(int historyLookbackDays) {
        this.historyLookbackDays = historyLookbackDays;
    }

    public int getRecentListingWindowDays() {
        return recentListingWindowDays;
    }

    public void setRecentListingWindowDays(int recentListingWindowDays) {
        this.recentListingWindowDays = recentListingWindowDays;
    }

    public int getRecentFundamentalListingWindowDays() {
        return recentFundamentalListingWindowDays;
    }

    public void setRecentFundamentalListingWindowDays(int recentFundamentalListingWindowDays) {
        this.recentFundamentalListingWindowDays = recentFundamentalListingWindowDays;
    }
}
