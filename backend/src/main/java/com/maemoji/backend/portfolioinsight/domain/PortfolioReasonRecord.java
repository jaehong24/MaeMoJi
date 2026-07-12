package com.maemoji.backend.portfolioinsight.domain;

public class PortfolioReasonRecord {

    private String reasonCode;
    private Integer displayOrder;

    public String getReasonCode() {
        return reasonCode;
    }

    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }
}
