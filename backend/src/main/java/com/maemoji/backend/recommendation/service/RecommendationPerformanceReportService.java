package com.maemoji.backend.recommendation.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class RecommendationPerformanceReportService {

    private final JdbcTemplate jdbcTemplate;

    public RecommendationPerformanceReportService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<RecommendationCohort> loadRecommendationCohorts() {
        return jdbcTemplate.query("""
                select
                    coalesce(engine_version, 'UNKNOWN') as engine_version,
                    coalesce(formula_version, 'UNKNOWN') as formula_version,
                    min(recommendation_date) as first_recommendation_date,
                    max(recommendation_date) as last_recommendation_date,
                    count(*) as recommendation_count
                from recommendations
                where coalesce(engine_version, '') <> 'ETF_PENDING'
                group by coalesce(engine_version, 'UNKNOWN'), coalesce(formula_version, 'UNKNOWN')
                order by first_recommendation_date, engine_version, formula_version
                """, (resultSet, rowNumber) -> new RecommendationCohort(
                resultSet.getString("engine_version"),
                resultSet.getString("formula_version"),
                resultSet.getObject("first_recommendation_date", LocalDate.class),
                resultSet.getObject("last_recommendation_date", LocalDate.class),
                resultSet.getLong("recommendation_count")
        ));
    }

    public List<PerformanceCohort> loadPerformanceCohorts() {
        return jdbcTemplate.query("""
                select
                    coalesce(engine_version, 'UNKNOWN') as engine_version,
                    coalesce(formula_version, 'UNKNOWN') as formula_version,
                    recommendation_status,
                    horizon_days,
                    count(*) as sample_count,
                    round(avg(stock_return_pct), 4) as avg_stock_return_pct,
                    round(avg(strategy_return_pct), 4) as avg_strategy_return_pct,
                    round(avg(excess_return_pct), 4) as avg_excess_return_pct,
                    round(avg(max_drawdown_pct), 4) as avg_max_drawdown_pct,
                    case
                        when recommendation_status = 'MAINTAIN' then null
                        else round(100.0 * avg(case when excess_return_pct > 0 then 1.0 else 0.0 end), 2)
                    end as excess_win_rate_pct
                from recommendation_performance_evaluations
                group by
                    coalesce(engine_version, 'UNKNOWN'),
                    coalesce(formula_version, 'UNKNOWN'),
                    recommendation_status,
                    horizon_days
                order by engine_version, formula_version, recommendation_status, horizon_days
                """, (resultSet, rowNumber) -> new PerformanceCohort(
                resultSet.getString("engine_version"),
                resultSet.getString("formula_version"),
                resultSet.getString("recommendation_status"),
                resultSet.getInt("horizon_days"),
                resultSet.getLong("sample_count"),
                resultSet.getBigDecimal("avg_stock_return_pct"),
                resultSet.getBigDecimal("avg_strategy_return_pct"),
                resultSet.getBigDecimal("avg_excess_return_pct"),
                resultSet.getBigDecimal("avg_max_drawdown_pct"),
                resultSet.getBigDecimal("excess_win_rate_pct")
        ));
    }

    public record RecommendationCohort(
            String engineVersion,
            String formulaVersion,
            LocalDate firstRecommendationDate,
            LocalDate lastRecommendationDate,
            long recommendationCount
    ) {
    }

    public record PerformanceCohort(
            String engineVersion,
            String formulaVersion,
            String recommendationStatus,
            int horizonDays,
            long sampleCount,
            BigDecimal averageStockReturnPct,
            BigDecimal averageStrategyReturnPct,
            BigDecimal averageExcessReturnPct,
            BigDecimal averageMaxDrawdownPct,
            BigDecimal excessWinRatePct
    ) {
    }
}
