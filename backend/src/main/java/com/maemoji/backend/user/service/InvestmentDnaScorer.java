package com.maemoji.backend.user.service;

import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Component
public class InvestmentDnaScorer {

    public ScoringResult calculate(List<Integer> answers) {
        if (answers == null || answers.size() != 12
                || answers.stream().anyMatch(answer -> answer == null || answer < 1 || answer > 5)) {
            throw new IllegalArgumentException("투자성향 설문은 12개 문항에 모두 답해주세요.");
        }

        final int score = answers.stream().mapToInt(Integer::intValue).sum();
        return resolveProfile(score);
    }

    ScoringResult resolveProfile(int score) {
        if (score < 12 || score > 60) {
            throw new IllegalArgumentException("투자성향 점수는 12점에서 60점 사이여야 합니다.");
        }
        if (score <= 24) {
            return new ScoringResult(
                    score,
                    "CONSERVATIVE",
                    "SAFE_FIRST",
                    "안전제일형",
                    "원금 보존을 가장 중요하게 생각하고 변동성에 민감한 편이에요.",
                    "예금, 적금, 채권처럼 흐름을 예측하기 쉬운 자산을 선호할 가능성이 높아요.",
                    allocation("현금", 40, "채권", 30, "ETF", 30)
            );
        }
        if (score <= 36) {
            return new ScoringResult(
                    score,
                    "BALANCED",
                    "BALANCE_SEEKER",
                    "균형추구형",
                    "안정성과 수익 가능성 사이의 균형을 중요하게 생각해요.",
                    "장기 ETF와 우량주를 중심으로 흔들림을 줄인 투자가 잘 맞을 수 있어요.",
                    allocation("ETF", 60, "우량주", 20, "채권·현금", 20)
            );
        }
        if (score <= 48) {
            return new ScoringResult(
                    score,
                    "BALANCED",
                    "GROWTH_SEEKER",
                    "성장추구형",
                    "미래 수익을 위해 현재 소비를 줄일 수 있고 장기 복리를 중요하게 생각해요.",
                    "아마존, 구글, 나스닥 ETF처럼 장기 성장 자산을 선호할 가능성이 높아요.",
                    allocation("미국 ETF", 50, "성장주", 30, "현금", 20)
            );
        }
        if (score <= 54) {
            return new ScoringResult(
                    score,
                    "AGGRESSIVE",
                    "AGGRESSIVE_INVESTOR",
                    "공격투자형",
                    "높은 변동성을 감수하면서 더 큰 장기 수익을 추구하는 편이에요.",
                    "성장주 비중을 높일 수 있지만 종목 집중과 급락 위험을 함께 관리해야 해요.",
                    allocation("성장주", 50, "ETF", 40, "현금", 10)
            );
        }
        return new ScoringResult(
                score,
                "AGGRESSIVE",
                "WEALTH_MASTER",
                "자산증식 마스터형",
                "소비보다 자산 형성과 경제적 자유에 큰 가치를 두는 편이에요.",
                "성장 자산을 적극적으로 활용하되 고위험 자산의 비중은 제한하는 전략이 좋아요.",
                allocation("ETF", 40, "성장주", 40, "테마·고위험", 10, "현금", 10)
        );
    }

    private Map<String, Integer> allocation(Object... values) {
        final Map<String, Integer> allocation = new LinkedHashMap<>();
        for (int index = 0; index < values.length; index += 2) {
            allocation.put((String) values[index], (Integer) values[index + 1]);
        }
        return allocation;
    }

    public record ScoringResult(
            int score,
            String riskProfile,
            String investmentDnaType,
            String title,
            String summary,
            String preference,
            Map<String, Integer> suggestedAllocation
    ) {
    }
}
