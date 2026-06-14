package com.maemoji.backend.user.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record RiskProfileSurveyRequest(
        @NotNull
        @Size(min = 12, max = 12)
        List<@Valid @NotNull @Min(1) @Max(5) Integer> answers,
        String source
) {
}
