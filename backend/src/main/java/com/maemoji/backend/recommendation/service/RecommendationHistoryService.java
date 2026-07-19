package com.maemoji.backend.recommendation.service;

import com.maemoji.backend.recommendation.domain.RecommendationHistoryRecord;
import com.maemoji.backend.recommendation.dto.RecommendationHistoryItemResponse;
import com.maemoji.backend.recommendation.mapper.RecommendationMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

@Service
public class RecommendationHistoryService {

    private static final int MEANINGFUL_SCORE_DELTA = 5;
    private static final int MAX_VISIBLE_HISTORY = 10;

    private final RecommendationMapper recommendationMapper;

    public RecommendationHistoryService(RecommendationMapper recommendationMapper) {
        this.recommendationMapper = recommendationMapper;
    }

    public List<RecommendationHistoryItemResponse> getHistory(Long userId, Long portfolioItemId) {
        final List<RecommendationHistoryRecord> newestFirst =
                recommendationMapper.findRecommendationHistory(userId, portfolioItemId, 40);
        if (newestFirst.isEmpty()) {
            return List.of();
        }

        final List<RecommendationHistoryRecord> chronological = new ArrayList<>(newestFirst);
        Collections.reverse(chronological);

        final List<RecommendationHistoryItemResponse> meaningful = new ArrayList<>();
        RecommendationHistoryRecord previous = null;
        for (RecommendationHistoryRecord current : chronological) {
            final RecommendationHistoryItemResponse item = toHistoryItem(previous, current);
            if (previous == null || isMeaningful(item, previous, current)) {
                meaningful.add(item);
            }
            previous = current;
        }

        Collections.reverse(meaningful);
        return meaningful.stream().limit(MAX_VISIBLE_HISTORY).toList();
    }

    private boolean isMeaningful(
            RecommendationHistoryItemResponse item,
            RecommendationHistoryRecord previous,
            RecommendationHistoryRecord current
    ) {
        return !Objects.equals(previous.recommendationStatus(), current.recommendationStatus())
                || Math.abs(item.scoreDelta()) >= MEANINGFUL_SCORE_DELTA
                || !Objects.equals(normalize(previous.coreFactorCode()), normalize(current.coreFactorCode()));
    }

    private RecommendationHistoryItemResponse toHistoryItem(
            RecommendationHistoryRecord previous,
            RecommendationHistoryRecord current
    ) {
        final int score = valueOrZero(current.engineScore());
        final Integer previousScore = previous == null ? null : valueOrZero(previous.engineScore());
        final int scoreDelta = previousScore == null ? 0 : score - previousScore;
        final boolean statusChanged = previous != null
                && !Objects.equals(previous.recommendationStatus(), current.recommendationStatus());
        final boolean reasonChanged = previous != null
                && !Objects.equals(normalize(previous.coreFactorCode()), normalize(current.coreFactorCode()));

        final String changeType;
        final String headline;
        if (previous == null) {
            changeType = "INITIAL";
            headline = "첫 추천 기록";
        } else if (statusChanged) {
            changeType = "STATUS_CHANGED";
            headline = statusLabel(previous.recommendationStatus()) + " -> "
                    + statusLabel(current.recommendationStatus());
        } else if (reasonChanged) {
            changeType = "REASON_CHANGED";
            headline = factorLabel(current.coreFactorCode());
        } else {
            changeType = "SCORE_CHANGED";
            headline = scoreDelta > 0 ? "점수가 높아졌어요" : "점수가 낮아졌어요";
        }

        return new RecommendationHistoryItemResponse(
                current.recommendationId(),
                current.recommendationDate(),
                current.generatedAt(),
                current.recommendationStatus(),
                previous == null ? null : previous.recommendationStatus(),
                score,
                previousScore,
                scoreDelta,
                changeType,
                headline,
                firstUsefulText(current.coreFactorSummary(), current.finalNote())
        );
    }

    private String firstUsefulText(String factorSummary, String finalNote) {
        final String source = !normalize(factorSummary).isEmpty() ? factorSummary.trim()
                : !normalize(finalNote).isEmpty() ? finalNote.trim()
                : "당시 가격과 기업 정보를 기준으로 추천을 계산했어요.";
        return source.length() <= 90 ? source : source.substring(0, 87).trim() + "...";
    }

    private int valueOrZero(Integer value) {
        return value == null ? 0 : value;
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }

    private String statusLabel(String status) {
        return switch (normalize(status)) {
            case "INCREASE" -> "증액";
            case "REDUCE" -> "축소";
            case "STOP" -> "중단";
            default -> "유지";
        };
    }

    private String factorLabel(String factorCode) {
        return switch (normalize(factorCode)) {
            case "PRICE_MOMENTUM" -> "가격 흐름이 달라졌어요";
            case "PRICE_STABILITY" -> "가격 안정성을 다시 봤어요";
            case "VALUATION" -> "가격 부담 판단이 달라졌어요";
            case "QUALITY_OF_GROWTH" -> "성장의 질을 다시 봤어요";
            case "FUNDAMENTAL_QUALITY" -> "기업 체력 판단이 달라졌어요";
            case "NEWS_SENTIMENT" -> "뉴스 흐름이 달라졌어요";
            case "USER_FIT" -> "내 투자 성향을 반영했어요";
            default -> "핵심 판단 근거가 달라졌어요";
        };
    }
}
