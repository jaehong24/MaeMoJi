package com.maemoji.backend.recommendation.service;

import com.maemoji.backend.recommendation.domain.RecommendationHistoryRecord;
import com.maemoji.backend.recommendation.dto.RecommendationHistoryItemResponse;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class RecommendationHistoryServiceTest {

    private final RecommendationMapper mapper = mock(RecommendationMapper.class);
    private final RecommendationHistoryService service = new RecommendationHistoryService(mapper);

    @Test
    void collapsesSmallRepeatedChangesAndKeepsMeaningfulEvents() {
        when(mapper.findRecommendationHistory(1L, 10L, 40)).thenReturn(List.of(
                record(5L, 5, "REDUCE", 61, "VALUATION", "가격 부담이 커졌어요."),
                record(4L, 4, "MAINTAIN", 68, "VALUATION", "가격 부담을 살폈어요."),
                record(3L, 3, "MAINTAIN", 70, "NEWS_SENTIMENT", "뉴스 흐름을 다시 봤어요."),
                record(2L, 2, "MAINTAIN", 72, "PRICE_MOMENTUM", "가격 흐름을 살폈어요."),
                record(1L, 1, "MAINTAIN", 70, "PRICE_MOMENTUM", "가격 흐름을 살폈어요.")
        ));

        final List<RecommendationHistoryItemResponse> result = service.getHistory(1L, 10L);

        assertThat(result).hasSize(4);
        assertThat(result.get(0).changeType()).isEqualTo("STATUS_CHANGED");
        assertThat(result.get(0).headline()).isEqualTo("유지 -> 축소");
        assertThat(result.get(1).changeType()).isEqualTo("REASON_CHANGED");
        assertThat(result.get(2).changeType()).isEqualTo("REASON_CHANGED");
        assertThat(result.get(3).changeType()).isEqualTo("INITIAL");
    }

    @Test
    void keepsScoreChangesAtOrAboveFivePoints() {
        when(mapper.findRecommendationHistory(2L, 20L, 40)).thenReturn(List.of(
                record(2L, 2, "MAINTAIN", 75, "VALUATION", "가격 부담을 살폈어요."),
                record(1L, 1, "MAINTAIN", 70, "VALUATION", "가격 부담을 살폈어요.")
        ));

        final List<RecommendationHistoryItemResponse> result = service.getHistory(2L, 20L);

        assertThat(result).hasSize(2);
        assertThat(result.get(0).changeType()).isEqualTo("SCORE_CHANGED");
        assertThat(result.get(0).scoreDelta()).isEqualTo(5);
    }

    private RecommendationHistoryRecord record(
            Long id,
            int day,
            String status,
            int score,
            String factorCode,
            String summary
    ) {
        return new RecommendationHistoryRecord(
                id,
                LocalDate.of(2026, 7, day),
                OffsetDateTime.parse("2026-07-01T09:00:00+09:00").plusDays(day - 1L),
                status,
                score,
                summary,
                factorCode,
                summary
        );
    }
}
