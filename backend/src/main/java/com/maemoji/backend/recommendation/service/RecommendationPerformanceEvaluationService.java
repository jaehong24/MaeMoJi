package com.maemoji.backend.recommendation.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class RecommendationPerformanceEvaluationService {

    private static final Logger log = LoggerFactory.getLogger(RecommendationPerformanceEvaluationService.class);

    private final JdbcTemplate jdbcTemplate;

    public RecommendationPerformanceEvaluationService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public int evaluateDueRecommendations(LocalDate evaluationDate) {
        final int inserted = jdbcTemplate.update("""
                insert into recommendation_performance_evaluations (
                    recommendation_id,
                    horizon_days,
                    recommendation_date,
                    evaluation_due_date,
                    baseline_date,
                    baseline_price,
                    evaluated_date,
                    evaluated_price,
                    recommendation_status,
                    engine_version,
                    formula_version,
                    stock_return_pct,
                    strategy_return_pct,
                    benchmark_return_pct,
                    excess_return_pct,
                    max_drawdown_pct
                )
                select
                    r.id,
                    horizon.days,
                    r.recommendation_date,
                    r.recommendation_date + horizon.days,
                    baseline.snapshot_date,
                    baseline.current_price,
                    evaluated.snapshot_date,
                    evaluated.current_price,
                    r.recommendation_status,
                    r.engine_version,
                    r.formula_version,
                    outcome.stock_return_pct,
                    outcome.stock_return_pct * exposure.multiplier,
                    outcome.stock_return_pct,
                    outcome.stock_return_pct * exposure.multiplier - outcome.stock_return_pct,
                    drawdown.max_drawdown_pct
                from recommendations r
                join portfolio_items pi on pi.id = r.portfolio_item_id
                join stocks s on s.id = pi.stock_id
                cross join (values (7), (30), (90)) as horizon(days)
                join lateral (
                    select p.snapshot_date, p.current_price
                    from stock_price_snapshots p
                    where p.stock_id = pi.stock_id
                      and p.snapshot_date &lt;= r.recommendation_date
                      and p.current_price &gt; 0
                    order by p.snapshot_date desc, p.id desc
                    limit 1
                ) baseline on true
                join lateral (
                    select p.snapshot_date, p.current_price
                    from stock_price_snapshots p
                    where p.stock_id = pi.stock_id
                      and p.snapshot_date &gt;= r.recommendation_date + horizon.days
                      and p.snapshot_date &lt;= ?
                      and p.current_price &gt; 0
                    order by p.snapshot_date asc, p.id asc
                    limit 1
                ) evaluated on true
                cross join lateral (
                    select ((evaluated.current_price / baseline.current_price) - 1) * 100 as stock_return_pct
                ) outcome
                cross join lateral (
                    select case
                        when r.current_amount &gt; 0 and r.recommended_amount &gt;= 0
                            then least(1.2, r.recommended_amount / r.current_amount)
                        when r.recommendation_status = 'INCREASE' then 1.2
                        when r.recommendation_status = 'MAINTAIN' then 1.0
                        when r.recommendation_status = 'REDUCE' then 0.7
                        else 0.0
                    end as multiplier
                ) exposure
                left join lateral (
                    select max(((path.running_peak - path.current_price) / nullif(path.running_peak, 0)) * 100)
                        as max_drawdown_pct
                    from (
                        select
                            p.current_price,
                            max(p.current_price) over (
                                order by p.snapshot_date asc
                                rows between unbounded preceding and current row
                            ) as running_peak
                        from stock_price_snapshots p
                        where p.stock_id = pi.stock_id
                          and p.snapshot_date between baseline.snapshot_date and evaluated.snapshot_date
                          and p.current_price &gt; 0
                    ) path
                ) drawdown on true
                where r.recommendation_date + horizon.days &lt;= ?
                  and coalesce(s.asset_type, 'STOCK') &lt;&gt; 'ETF'
                  and coalesce(r.engine_version, '') &lt;&gt; 'ETF_PENDING'
                on conflict (recommendation_id, horizon_days) do nothing
                """, evaluationDate, evaluationDate);
        log.info("추천 성과 만기 평가를 완료했습니다. evaluationDate={}, inserted={}", evaluationDate, inserted);
        return inserted;
    }
}
