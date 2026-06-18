package com.maemoji.backend.recommendation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import com.maemoji.backend.recommendation.domain.NewsAnalysisCacheRecord;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class NewsSentimentServiceRegressionTest {

    private final RecommendationMapper recommendationMapper = mock(RecommendationMapper.class);
    private final NewsSentimentService service = new NewsSentimentService(
            new ObjectMapper(),
            recommendationMapper
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
                        news("positive-1", "수주 확대", 80, 100, "HIGH", 80),
                        news("positive-2", "실적 성장", 70, 100, "HIGH", 70),
                        news("hard-negative", "guidance cut after weak demand", -85, 100, "HIGH", -85)
                ),
                true
        );

        assertThat(result.weightedSentimentScore()).isEqualTo(-70);
        assertThat(result.score()).isEqualTo(1);
        assertThat(result.label()).isEqualTo("NEGATIVE");
        assertThat(result.hardNegativeOverride()).isTrue();
        assertThat(result.hardNegativeCategory()).isEqualTo("GUIDANCE_OR_EARNINGS");
    }

    @Test
    void classifiesAccountingFraudAsMostSevereNegativeCategory() throws Exception {
        final NewsSentimentService.NewsSentimentResult result = finalizeResult(
                List.of(
                        news("hard-negative", "accounting fraud investigation", -90, 95, "HIGH", -90)
                ),
                true
        );

        assertThat(result.hardNegativeCategory()).isEqualTo("ACCOUNTING_OR_FRAUD");
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

    @Test
    void excludesOldCachedNewsFromRecommendationScores() {
        final NewsAnalysisCacheRecord stale = cachedNews(
                OffsetDateTime.now(ZoneOffset.UTC).minusDays(10)
        );
        when(recommendationMapper.findLatestNewsAnalysisByStockId(77L))
                .thenReturn(List.of(stale));

        assertThat(service.findCachedDisplayResult(77L)).isNull();
    }

    @Test
    void reusesFreshCachedNews() {
        final NewsAnalysisCacheRecord fresh = cachedNews(
                OffsetDateTime.now(ZoneOffset.UTC)
        );
        when(recommendationMapper.findLatestNewsAnalysisByStockId(78L))
                .thenReturn(List.of(fresh));

        assertThat(service.findCachedDisplayResult(78L)).isNotNull();
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
            String headline,
            int sentimentScore,
            int relevanceScore,
            String impactLevel,
            double weightedScore
    ) {
        return new NewsSentimentService.AnalyzedNewsItem(
                contentHash,
                "AAPL",
                headline,
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

    private NewsSentimentService.AnalyzedNewsItem news(
            String contentHash,
            int sentimentScore,
            int relevanceScore,
            String impactLevel,
            double weightedScore
    ) {
        return news(contentHash, "테스트 뉴스", sentimentScore, relevanceScore, impactLevel, weightedScore);
    }

    private NewsAnalysisCacheRecord cachedNews(OffsetDateTime publishedAt) {
        final NewsAnalysisCacheRecord record = new NewsAnalysisCacheRecord();
        record.setStockId(77L);
        record.setNewsId("news-1");
        record.setSymbol("AAPL");
        record.setNewsPublishedAt(publishedAt);
        record.setHeadline("Apple reports results");
        record.setSummary("요약");
        record.setSourceName("TEST");
        record.setNewsUrl("https://example.com/news");
        record.setSentimentLabel("POSITIVE");
        record.setSentimentScore(50);
        record.setKeywordScore(10);
        record.setRelevanceScore(90);
        record.setImpactLevel("MEDIUM");
        record.setReason("관련성이 높은 최신 기사");
        record.setContentHash("content-hash");
        record.setAnalysisBatchHash("batch-hash");
        record.setLlmModel("gemini-2.5-flash-lite");
        record.setAnalyzedAt(OffsetDateTime.now(ZoneOffset.UTC));
        return record;
    }
}
