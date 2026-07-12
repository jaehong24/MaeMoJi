package com.maemoji.backend.portfolioinsight.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record PortfolioReasonUpdateRequest(
        @NotNull(message = "투자 이유 목록이 필요합니다.")
        @Size(max = 3, message = "투자 이유는 최대 3개까지만 선택할 수 있습니다.")
        List<String> reasons
) {
}
