package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class NewsSentimentServiceRegressionTest {

    private final NewsSentimentService service = new NewsSentimentService(
            new ObjectMapper(),
            mock(RecommendationMapper.class)
    );

    @Test
    void appliesSingleArticleEvidenceFactorAndConfidence() throws Exception {
        final NewsSentimentService.NewsSentimentResult result = finalizeResult(
                List.of(news("positive", 80, 100, "HIGH", 80)),
                false
        );

        assertThat(result.weightedSentimentScore()).isEqualTo(52);
        assertThat(result.score()).isEqualTo(13);
        assertThat(result.label()).isEqualTo("POSITIVE");
        assertThat(result.analysisConfidence()).isEqualTo(82);
    }

    @Test
    void strongNegativeNewsOverridesPositiveAggregate() throws Exception {
        final NewsSentimentService.NewsSentimentResult result = finalizeResult(
                List.of(
                        news("positive-1", 80, 100, "HIGH", 80),
                        news("positive-2", 70, 100, "HIGH", 70),
                        news("hard-negative", -85, 100, "HIGH", -85)
                ),
                true
        );

        assertThat(result.weightedSentimentScore()).isEqualTo(-70);
        assertThat(result.score()).isEqualTo(1);
        assertThat(result.label()).isEqualTo("NEGATIVE");
        assertThat(result.hardNegativeOverride()).isTrue();
    }

    @Test
    void keepsExistingCacheWhenNoNewsOrGeminiFailureOccurs() {
        assertThat(NewsSentimentService.NewsSentimentResult.empty().replaceCache()).isFalse();
        assertThat(NewsSentimentService.NewsSentimentResult.geminiUnavailable().replaceCache()).isFalse();
    }

    @Test
    void retriesOnlyTemporaryGeminiFailures() {
        assertThat(service.isRetryableGeminiStatus(429)).isTrue();
        assertThat(service.isRetryableGeminiStatus(503)).isTrue();
        assertThat(service.isRetryableGeminiStatus(504)).isTrue();
        assertThat(service.isRetryableGeminiStatus(400)).isFalse();
        assertThat(service.isRetryableGeminiStatus(403)).isFalse();
    }

    private NewsSentimentService.NewsSentimentResult finalizeResult(
            List<NewsSentimentService.AnalyzedNewsItem> news,
            boolean hardNegativeOverride
    ) throws Exception {
        final Method method = NewsSentimentService.class.getDeclaredMethod(
                "finalizeResult",
                List.class,
                boolean.class,
                String.class,
                String.class,
                boolean.class,
                boolean.class
        );
        method.setAccessible(true);
        return (NewsSentimentService.NewsSentimentResult) method.invoke(
                service,
                news,
                hardNegativeOverride,
                "테스트 요약",
                "gemini-2.5-flash",
                false,
                true
        );
    }

    private NewsSentimentService.AnalyzedNewsItem news(
            String contentHash,
            int sentimentScore,
            int relevanceScore,
            String impactLevel,
            double weightedScore
    ) {
        return new NewsSentimentService.AnalyzedNewsItem(
                contentHash,
                "AAPL",
                "테스트 뉴스",
                "테스트 요약",
                "TEST",
                "https://example.com/" + contentHash,
                OffsetDateTime.now(ZoneOffset.UTC),
                sentimentScore >= 15 ? "POSITIVE" : sentimentScore <= -15 ? "NEGATIVE" : "NEUTRAL",
                sentimentScore,
                0,
                relevanceScore,
                impactLevel,
                "테스트 판단 근거",
                BigDecimal.ONE,
                BigDecimal.ONE,
                BigDecimal.valueOf(weightedScore),
                contentHash,
                "batch-hash"
        );
    }
}
