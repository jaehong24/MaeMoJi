package com.maemoji.backend.recommendation.service;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RecommendationPerformanceReportServiceTest {

    @Test
    void groupsPerformanceWithoutMixingModelVersions() {
        final JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        when(jdbcTemplate.query(anyString(), any(RowMapper.class))).thenReturn(List.of());
        final RecommendationPerformanceReportService service =
                new RecommendationPerformanceReportService(jdbcTemplate);

        service.loadPerformanceCohorts();

        final ArgumentCaptor<String> sqlCaptor = ArgumentCaptor.forClass(String.class);
        verify(jdbcTemplate).query(sqlCaptor.capture(), any(RowMapper.class));
        assertThat(sqlCaptor.getValue())
                .contains("engine_version")
                .contains("formula_version")
                .contains("recommendation_status")
                .contains("horizon_days")
                .contains("excess_win_rate_pct")
                .contains("group by");
    }
}
