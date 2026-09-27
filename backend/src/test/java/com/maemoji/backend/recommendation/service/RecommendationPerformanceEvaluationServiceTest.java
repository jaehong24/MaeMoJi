package com.maemoji.backend.recommendation.service;

import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RecommendationPerformanceEvaluationServiceTest {

    @Test
    void evaluatesAllDueHorizonsWithOneIdempotentStatement() {
        final JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        final LocalDate evaluationDate = LocalDate.of(2026, 9, 27);
        when(jdbcTemplate.update(anyString(), eq(evaluationDate), eq(evaluationDate))).thenReturn(12);

        final int inserted = new RecommendationPerformanceEvaluationService(jdbcTemplate)
                .evaluateDueRecommendations(evaluationDate);

        assertThat(inserted).isEqualTo(12);
        verify(jdbcTemplate).update(anyString(), eq(evaluationDate), eq(evaluationDate));
    }
}
