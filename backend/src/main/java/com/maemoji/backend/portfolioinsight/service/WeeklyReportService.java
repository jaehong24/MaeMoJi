package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.RecommendationTrendRow;
import com.maemoji.backend.portfolioinsight.domain.WeeklyReportItemRecord;
import com.maemoji.backend.portfolioinsight.domain.WeeklyReportRecord;
import com.maemoji.backend.portfolioinsight.dto.WeeklyReportItemResponse;
import com.maemoji.backend.portfolioinsight.dto.WeeklyReportListItemResponse;
import com.maemoji.backend.portfolioinsight.dto.WeeklyReportResponse;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class WeeklyReportService {

    private static final ZoneId HOME_ZONE = ZoneId.of("Asia/Seoul");
    private static final String SUPPLEMENTAL_PRICE_RISK_TEXT = "가격 흐름도 함께 흔들려";

    private final PortfolioInsightMapper portfolioInsightMapper;
    private final PushNotificationDispatchService pushNotificationDispatchService;
    private final WeeklyDigestNotificationService weeklyDigestNotificationService;

    public WeeklyReportService(
            PortfolioInsightMapper portfolioInsightMapper,
            PushNotificationDispatchService pushNotificationDispatchService,
            WeeklyDigestNotificationService weeklyDigestNotificationService
    ) {
        this.portfolioInsightMapper = portfolioInsightMapper;
        this.pushNotificationDispatchService = pushNotificationDispatchService;
        this.weeklyDigestNotificationService = weeklyDigestNotificationService;
    }

    @Transactional
    public WeeklyReportResponse generateLatestReport(Long userId) {
        final LocalDate reportWeek = LocalDate.now(HOME_ZONE).with(DayOfWeek.MONDAY);
        final OffsetDateTime generatedAt = OffsetDateTime.now(HOME_ZONE);
        final List<RecommendationTrendRow> trendRows = portfolioInsightMapper.findRecommendationTrendRowsByUserId(userId);
        final List<ResolvedTrend> trends = resolveTrends(trendRows);

        final List<ResolvedTrend> sortedTrends = trends.stream()
                .sorted((left, right) -> Integer.compare(
                        Math.abs(right.scoreDelta()),
                        Math.abs(left.scoreDelta())
                ))
                .toList();

        final int changedItemCount = (int) sortedTrends.stream().filter(ResolvedTrend::isChanged).count();
        final int alertItemCount = (int) sortedTrends.stream().filter(ResolvedTrend::isAlert).count();
        final int positiveItemCount = (int) sortedTrends.stream().filter(ResolvedTrend::isPositive).count();
        final int negativeItemCount = (int) sortedTrends.stream().filter(ResolvedTrend::isNegative).count();

        final String headline = buildHeadline(changedItemCount, alertItemCount);
        final String summary = buildSummary(changedItemCount, positiveItemCount, negativeItemCount);

        portfolioInsightMapper.deleteWeeklyReportByUserIdAndWeek(userId, reportWeek);
        portfolioInsightMapper.insertWeeklyReport(
                userId,
                reportWeek,
                generatedAt,
                headline,
                summary,
                changedItemCount,
                alertItemCount,
                positiveItemCount,
                negativeItemCount
        );

        final Long reportId = portfolioInsightMapper.findWeeklyReportIdByUserIdAndWeek(userId, reportWeek);
        for (int index = 0; index < sortedTrends.size(); index++) {
            final ResolvedTrend trend = sortedTrends.get(index);
            portfolioInsightMapper.insertWeeklyReportItem(
                    reportId,
                    trend.current().getPortfolioItemId(),
                    trend.current().getStockId(),
                    trend.current().getRecommendationStatus(),
                    trend.previousStatus(),
                    trend.scoreDelta(),
                    trend.headlineLabel(),
                    trend.changeType(),
                    trend.summary(),
                    index
            );
            if (trend.shouldCreateAlert()) {
                final String dedupeKey =
                        userId + ":" + reportWeek + ":" + trend.current().getPortfolioItemId() + ":" + trend.changeType();
                portfolioInsightMapper.insertAlertEvent(
                        userId,
                        trend.current().getPortfolioItemId(),
                        trend.current().getStockId(),
                        trend.changeType(),
                        buildAlertTitle(trend.current().getCompanyName(), trend.headlineLabel()),
                        trend.summary(),
                        dedupeKey,
                        generatedAt
                );
                final var alertEvent = portfolioInsightMapper.findAlertByDedupeKey(userId, dedupeKey);
                if (alertEvent != null) {
                    pushNotificationDispatchService.dispatchImmediate(userId, alertEvent);
                }
            }
        }
        final WeeklyReportResponse response = getLatestReport(userId);
        weeklyDigestNotificationService.dispatchWeeklyDigest(userId, response);
        return response;
    }

    public WeeklyReportResponse getLatestReport(Long userId) {
        WeeklyReportRecord record = portfolioInsightMapper.findLatestWeeklyReportByUserId(userId);
        if (record == null) {
            return generateLatestReport(userId);
        }

        final List<WeeklyReportItemResponse> items = portfolioInsightMapper.findWeeklyReportItemsByReportId(record.getId()).stream()
                .map(this::toItemResponse)
                .toList();

        return new WeeklyReportResponse(
                record.getId(),
                record.getReportWeek(),
                record.getGeneratedAt(),
                record.getHeadline(),
                record.getSummary(),
                value(record.getChangedItemCount()),
                value(record.getAlertItemCount()),
                value(record.getPositiveItemCount()),
                value(record.getNegativeItemCount()),
                items
        );
    }

    public List<WeeklyReportListItemResponse> getWeeklyReports(Long userId) {
        return portfolioInsightMapper.findWeeklyReportsByUserId(userId).stream()
                .map(record -> new WeeklyReportListItemResponse(
                        record.getId(),
                        record.getReportWeek(),
                        record.getGeneratedAt(),
                        record.getHeadline(),
                        value(record.getChangedItemCount()),
                        value(record.getAlertItemCount())
                ))
                .toList();
    }

    private List<ResolvedTrend> resolveTrends(List<RecommendationTrendRow> rows) {
        final Map<Long, RecommendationTrendRow> latestByPortfolioItemId = new LinkedHashMap<>();
        final Map<Long, RecommendationTrendRow> previousByPortfolioItemId = new LinkedHashMap<>();

        for (RecommendationTrendRow row : rows) {
            if (value(row.getRowNumber()) == 1) {
                latestByPortfolioItemId.put(row.getPortfolioItemId(), row);
            } else if (value(row.getRowNumber()) == 2) {
                previousByPortfolioItemId.put(row.getPortfolioItemId(), row);
            }
        }

        final List<ResolvedTrend> trends = new ArrayList<>();
        for (RecommendationTrendRow current : latestByPortfolioItemId.values()) {
            final RecommendationTrendRow previous = previousByPortfolioItemId.get(current.getPortfolioItemId());
            trends.add(buildTrend(current, previous));
        }
        return trends;
    }

    private ResolvedTrend buildTrend(RecommendationTrendRow current, RecommendationTrendRow previous) {
        final int currentScore = value(current.getEngineScore());
        final int previousScore = previous == null ? currentScore : value(previous.getEngineScore());
        final int scoreDelta = currentScore - previousScore;
        final String previousStatus = previous == null ? null : previous.getRecommendationStatus();

        if (previous == null) {
            return new ResolvedTrend(
                    current,
                    null,
                    scoreDelta,
                    "새로 분석",
                    "NEW_ENTRY",
                    current.getCompanyName() + "은 이번 주 처음 리포트에 포함되었어요."
            );
        }

        final int newsDelta = value(current.getNewsScore()) - value(previous.getNewsScore());
        final int momentumDelta = value(current.getPriceMomentumScore()) - value(previous.getPriceMomentumScore());
        final int stabilityDelta = value(current.getPriceStabilityScore()) - value(previous.getPriceStabilityScore());
        final int fundamentalDelta = value(current.getFundamentalQualityScore()) - value(previous.getFundamentalQualityScore());
        final boolean supplementalPriceRisk = hasSupplementalPriceRiskSignal(current, momentumDelta, stabilityDelta);

        if (!safeEquals(current.getRecommendationStatus(), previousStatus)) {
            final String currentStatus = current.getRecommendationStatus();
            final boolean isDowngraded = "REDUCE".equals(currentStatus) || "STOP".equals(currentStatus);
            final boolean isUpgraded = "INCREASE".equals(currentStatus);
            return new ResolvedTrend(
                    current,
                    previousStatus,
                    scoreDelta,
                    isDowngraded ? "의견 하향" : isUpgraded ? "의견 상향" : "의견 조정",
                    isDowngraded ? "STATUS_DOWNGRADED" : isUpgraded ? "STATUS_UPGRADED" : "STATUS_REBALANCED",
                    buildStatusChangeSummary(
                            current.getCompanyName(),
                            previousStatus,
                            current.getRecommendationStatus(),
                            supplementalPriceRisk
                    )
            );
        }

        if (newsDelta >= 8) {
            return new ResolvedTrend(
                    current,
                    previousStatus,
                    scoreDelta,
                    "뉴스 개선",
                    "NEWS_IMPROVED",
                    current.getCompanyName() + "은 최근 뉴스 분위기가 좋아져 다시 볼 이유가 생겼어요."
            );
        }
        if (newsDelta <= -8) {
            return new ResolvedTrend(
                    current,
                    previousStatus,
                    scoreDelta,
                    "뉴스 악화",
                    "NEWS_WEAKENED",
                    current.getCompanyName() + "은 최근 뉴스 분위기가 약해져 한 번 더 확인하는 편이 좋아요."
            );
        }
        if (isPriceRiskTrend(current, momentumDelta, stabilityDelta)) {
            return new ResolvedTrend(
                    current,
                    previousStatus,
                    scoreDelta,
                    "가격 흔들림",
                    "PRICE_RISK",
                    current.getCompanyName() + "은 최근 가격 흐름이 흔들려 보수적으로 볼 필요가 있어요."
            );
        }
        if (momentumDelta >= 9 || stabilityDelta >= 9) {
            return new ResolvedTrend(
                    current,
                    previousStatus,
                    scoreDelta,
                    "가격 안정",
                    "PRICE_IMPROVED",
                    current.getCompanyName() + "은 최근 가격 흐름이 한층 안정적으로 반영됐어요."
            );
        }
        if (fundamentalDelta >= 6) {
            return new ResolvedTrend(
                    current,
                    previousStatus,
                    scoreDelta,
                    "기업 체력 반영",
                    "FUNDAMENTAL_IMPROVED",
                    current.getCompanyName() + "은 기업 체력 판단이 좋아져 장기 관점이 조금 더 단단해졌어요."
            );
        }

        final String maintainHeadline = scoreDelta >= 0 ? "다시 확인" : "보수적 유지";
        final String maintainChangeType = scoreDelta >= 0 ? "STABLE_REVIEW" : "CAUTIOUS_MAINTAIN";
        final String maintainSummary = scoreDelta >= 0
                ? current.getCompanyName() + "은 큰 방향 변화는 없지만 이번 주 한 번 더 점검해볼 만해요."
                : current.getCompanyName() + "은 큰 변화는 없지만 조금 더 보수적으로 보는 흐름이에요.";

        return new ResolvedTrend(
                current,
                previousStatus,
                scoreDelta,
                maintainHeadline,
                maintainChangeType,
                maintainSummary
        );
    }

    private boolean hasSupplementalPriceRiskSignal(
            RecommendationTrendRow current,
            int momentumDelta,
            int stabilityDelta
    ) {
        final int currentMomentum = value(current.getPriceMomentumScore());
        final int currentStability = value(current.getPriceStabilityScore());
        return ((momentumDelta <= -6 && currentMomentum <= 50)
                || (stabilityDelta <= -6 && currentStability <= 52))
                || ((momentumDelta <= -4 || stabilityDelta <= -4)
                && currentMomentum <= 46
                && currentStability <= 48);
    }

    private boolean isPriceRiskTrend(
            RecommendationTrendRow current,
            int momentumDelta,
            int stabilityDelta
    ) {
        if (momentumDelta <= -9 || stabilityDelta <= -9) {
            return true;
        }
        final int currentMomentum = value(current.getPriceMomentumScore());
        final int currentStability = value(current.getPriceStabilityScore());
        if ((momentumDelta <= -6 && currentMomentum <= 46)
                || (stabilityDelta <= -6 && currentStability <= 48)) {
            return true;
        }
        return (momentumDelta <= -4 || stabilityDelta <= -4)
                && currentMomentum <= 42
                && currentStability <= 45;
    }

    private WeeklyReportItemResponse toItemResponse(WeeklyReportItemRecord record) {
        return new WeeklyReportItemResponse(
                record.getPortfolioItemId(),
                record.getStockId(),
                record.getCompanyName(),
                record.getTicker(),
                record.getLogoUrl(),
                record.getCurrentStatus(),
                record.getPreviousStatus(),
                value(record.getScoreDelta()),
                record.getHeadlineLabel(),
                record.getChangeType(),
                record.getSummary(),
                hasSupplementalPriceRiskText(record.getSummary())
        );
    }

    private String buildHeadline(int changedItemCount, int alertItemCount) {
        if (alertItemCount > 0) {
            return "이번 주 다시 볼 종목이 " + alertItemCount + "개 있어요";
        }
        if (changedItemCount > 0) {
            return "이번 주 포트폴리오에 변화가 생겼어요";
        }
        return "이번 주 포트폴리오는 큰 방향 변화 없이 유지되고 있어요";
    }

    private String buildSummary(int changedItemCount, int positiveItemCount, int negativeItemCount) {
        if (changedItemCount == 0) {
            return "점수와 추천 상태가 크게 흔들린 종목은 없었어요.";
        }
        return "좋아진 종목 " + positiveItemCount + "개, 주의가 필요한 종목 " + negativeItemCount
                + "개를 중심으로 이번 주 변화를 정리했어요.";
    }

    private String buildAlertTitle(String companyName, String headlineLabel) {
        return companyName + " · " + headlineLabel;
    }

    private String buildStatusChangeSummary(
            String companyName,
            String previousStatus,
            String currentStatus,
            boolean supplementalPriceRisk
    ) {
        final String base = companyName + "은 " + toKoreanStatus(previousStatus)
                + "에서 " + toKoreanStatus(currentStatus)
                + " 쪽으로 의견이 바뀌었어요.";
        if (!supplementalPriceRisk) {
            return base;
        }
        return base + " " + SUPPLEMENTAL_PRICE_RISK_TEXT + " 조금 더 보수적으로 확인하는 편이 좋아요.";
    }

    public static boolean hasSupplementalPriceRiskText(String text) {
        return text != null && text.contains(SUPPLEMENTAL_PRICE_RISK_TEXT);
    }

    private String toKoreanStatus(String status) {
        if (status == null) {
            return "새 분석";
        }
        return switch (status) {
            case "INCREASE" -> "증액";
            case "MAINTAIN" -> "유지";
            case "REDUCE" -> "감액";
            case "STOP" -> "중단";
            default -> status;
        };
    }

    private int value(Integer value) {
        return value == null ? 0 : value;
    }

    private boolean safeEquals(String left, String right) {
        return left == null ? right == null : left.equals(right);
    }

    private record ResolvedTrend(
            RecommendationTrendRow current,
            String previousStatus,
            int scoreDelta,
            String headlineLabel,
            String changeType,
            String summary
    ) {
        boolean isChanged() {
            return !safeEquals(current.getRecommendationStatus(), previousStatus) || Math.abs(scoreDelta) >= 5;
        }

        boolean isAlert() {
            return "STATUS_DOWNGRADED".equals(changeType)
                    || "NEWS_WEAKENED".equals(changeType)
                    || "PRICE_RISK".equals(changeType);
        }

        boolean isPositive() {
            return scoreDelta >= 5 || "NEWS_IMPROVED".equals(changeType) || "PRICE_IMPROVED".equals(changeType);
        }

        boolean isNegative() {
            return scoreDelta <= -5 || "NEWS_WEAKENED".equals(changeType) || "PRICE_RISK".equals(changeType);
        }

        boolean shouldCreateAlert() {
            return isAlert();
        }

        private boolean safeEquals(String left, String right) {
            return left == null ? right == null : left.equals(right);
        }
    }
}
