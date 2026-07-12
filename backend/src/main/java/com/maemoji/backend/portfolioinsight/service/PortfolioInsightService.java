package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.domain.PortfolioReasonRecord;
import com.maemoji.backend.portfolioinsight.dto.PortfolioReasonOptionResponse;
import com.maemoji.backend.portfolioinsight.dto.PortfolioReasonResponse;
import com.maemoji.backend.portfolioinsight.dto.PortfolioReasonUpdateRequest;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class PortfolioInsightService {

    private static final Map<String, PortfolioReasonOptionResponse> REASON_OPTIONS = Map.ofEntries(
            Map.entry("LONG_TERM_GROWTH", new PortfolioReasonOptionResponse("LONG_TERM_GROWTH", "장기 성장", "시간이 지날수록 성장이 이어질 거라고 봤어요.")),
            Map.entry("PRICE_PULLBACK", new PortfolioReasonOptionResponse("PRICE_PULLBACK", "가격 조정", "최근 조정 구간이 매수 기회라고 판단했어요.")),
            Map.entry("AI_GROWTH", new PortfolioReasonOptionResponse("AI_GROWTH", "AI/기술 성장", "AI와 기술 성장 수혜를 기대하고 있어요.")),
            Map.entry("DIVIDEND", new PortfolioReasonOptionResponse("DIVIDEND", "배당", "꾸준한 배당과 현금흐름을 기대하고 있어요.")),
            Map.entry("QUALITY_CORE", new PortfolioReasonOptionResponse("QUALITY_CORE", "우량주 장기 보유", "기본 체력이 좋은 핵심 종목으로 보고 있어요.")),
            Map.entry("DIVERSIFICATION", new PortfolioReasonOptionResponse("DIVERSIFICATION", "분산 투자", "포트폴리오 균형을 위해 담았어요.")),
            Map.entry("DEFENSIVE_BALANCE", new PortfolioReasonOptionResponse("DEFENSIVE_BALANCE", "방어형 보강", "변동성을 줄이기 위한 목적이에요.")),
            Map.entry("REBOUND_EXPECTATION", new PortfolioReasonOptionResponse("REBOUND_EXPECTATION", "반등 기대", "최근 약세 뒤 반등 가능성을 보고 있어요.")),
            Map.entry("NEWS_EVENT", new PortfolioReasonOptionResponse("NEWS_EVENT", "뉴스/이슈", "최근 이슈와 이벤트를 보고 관심을 가졌어요."))
    );

    private final PortfolioInsightMapper portfolioInsightMapper;

    public PortfolioInsightService(PortfolioInsightMapper portfolioInsightMapper) {
        this.portfolioInsightMapper = portfolioInsightMapper;
    }

    public List<PortfolioReasonOptionResponse> getReasonOptions() {
        return List.of(
                REASON_OPTIONS.get("LONG_TERM_GROWTH"),
                REASON_OPTIONS.get("PRICE_PULLBACK"),
                REASON_OPTIONS.get("AI_GROWTH"),
                REASON_OPTIONS.get("DIVIDEND"),
                REASON_OPTIONS.get("QUALITY_CORE"),
                REASON_OPTIONS.get("DIVERSIFICATION"),
                REASON_OPTIONS.get("DEFENSIVE_BALANCE"),
                REASON_OPTIONS.get("REBOUND_EXPECTATION"),
                REASON_OPTIONS.get("NEWS_EVENT")
        );
    }

    @Transactional
    public List<PortfolioReasonResponse> updatePortfolioReasons(
            Long userId,
            Long portfolioItemId,
            PortfolioReasonUpdateRequest request
    ) {
        requireOwnedPortfolioItem(userId, portfolioItemId);

        final List<String> normalizedReasons = normalizeReasons(request.reasons());
        portfolioInsightMapper.deletePortfolioReasons(portfolioItemId);
        for (int index = 0; index < normalizedReasons.size(); index++) {
            portfolioInsightMapper.insertPortfolioReason(portfolioItemId, normalizedReasons.get(index), index);
        }
        return getPortfolioReasons(userId, portfolioItemId);
    }

    public List<PortfolioReasonResponse> getPortfolioReasons(Long userId, Long portfolioItemId) {
        requireOwnedPortfolioItem(userId, portfolioItemId);
        return portfolioInsightMapper.findPortfolioReasons(userId, portfolioItemId).stream()
                .map(this::toReasonResponse)
                .toList();
    }

    private void requireOwnedPortfolioItem(Long userId, Long portfolioItemId) {
        final Long ownedId = portfolioInsightMapper.findOwnedActivePortfolioItemId(userId, portfolioItemId);
        if (ownedId == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "포트폴리오 종목을 찾을 수 없습니다.");
        }
    }

    private List<String> normalizeReasons(List<String> rawReasons) {
        if (rawReasons == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "투자 이유 목록이 필요합니다.");
        }

        final List<String> normalized = rawReasons.stream()
                .filter(reason -> reason != null && !reason.isBlank())
                .map(reason -> reason.trim().toUpperCase(Locale.ROOT))
                .distinct()
                .toList();

        if (normalized.size() > 3) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "투자 이유는 최대 3개까지만 선택할 수 있습니다.");
        }

        final LinkedHashSet<String> unique = new LinkedHashSet<>(normalized);
        for (String reason : unique) {
            if (!REASON_OPTIONS.containsKey(reason)) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "지원하지 않는 투자 이유가 포함되어 있습니다: " + reason);
            }
        }

        return List.copyOf(unique);
    }

    private PortfolioReasonResponse toReasonResponse(PortfolioReasonRecord record) {
        final PortfolioReasonOptionResponse option = REASON_OPTIONS.get(record.getReasonCode());
        final String label = option == null ? record.getReasonCode() : option.label();
        return new PortfolioReasonResponse(record.getReasonCode(), label);
    }
}
