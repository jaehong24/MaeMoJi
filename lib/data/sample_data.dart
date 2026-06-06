import '../models/evidence_item.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_status.dart';

/// 실제 API 연동 전까지 화면 흐름을 검증하기 위한 샘플 데이터입니다.
const sampleRecommendations = [
  RecommendationItem(
    name: 'NVIDIA',
    ticker: 'NVDA',
    currentAmount: '12,000원',
    recommendedAmount: '8,400원',
    confidence: 82,
    currentHolding: '2.38주',
    startedAt: '2025.11.02',
    memo: 'AI 반도체 장기 적립 중',
    score: 52,
    note: '최근 30일 급등과 밸류에이션 부담이 함께 나타나 축소 의견이 나왔습니다.',
    status: RecommendationStatus.reduce,
    evidence: [
      EvidenceItem(
        title: '주가 분석',
        body: '최근 30일 +35% 상승으로 단기 과열 가능성이 감지되었습니다.',
      ),
      EvidenceItem(
        title: '뉴스 분석',
        body: '긍정 뉴스 12건, 부정 뉴스 7건으로 전체 뉴스 점수는 +4입니다.',
      ),
      EvidenceItem(
        title: '기관 수급 분석',
        body: '기관 순매수 둔화가 관측되어 기관 점수는 -10으로 계산되었습니다.',
      ),
      EvidenceItem(
        title: '밸류에이션 분석',
        body: 'PER이 업종 평균 대비 +48% 높아 가격 부담 신호가 있습니다.',
      ),
      EvidenceItem(
        title: '실적 분석',
        body: '실적 자체는 여전히 견조하지만, 현재 가격 부담을 상쇄할 정도는 아닙니다.',
      ),
      EvidenceItem(
        title: 'AI 최종 의견',
        body: '장기 성장성은 우수하지만 현재는 적립 금액을 일부 줄이는 전략이 적절합니다.',
      ),
    ],
  ),
  RecommendationItem(
    name: 'DRAM ETF',
    ticker: 'DRAM',
    currentAmount: '12,000원',
    recommendedAmount: '14,400원',
    confidence: 79,
    currentHolding: '15좌',
    startedAt: '2026.01.18',
    memo: '반도체 사이클 회복 기대',
    score: 84,
    note: '산업 수요 회복과 기관 관심이 이어져 적립 금액을 소폭 늘리는 안이 적절합니다.',
    status: RecommendationStatus.increase,
    evidence: [
      EvidenceItem(
        title: '주가 분석',
        body: '최근 30일 수익률이 안정 구간에 머물러 과열 부담이 크지 않습니다.',
      ),
      EvidenceItem(
        title: '뉴스 분석',
        body: '메모리 업황 회복 뉴스 비중이 높아 뉴스 점수는 +7입니다.',
      ),
      EvidenceItem(
        title: '기관 수급 분석',
        body: '기관 비중이 완만하게 증가하고 있어 수급 점수는 +10입니다.',
      ),
      EvidenceItem(
        title: '밸류에이션 분석',
        body: '업종 평균 대비 과한 프리미엄 없이 적정 수준으로 평가됩니다.',
      ),
      EvidenceItem(
        title: '실적 분석',
        body: '실적 가이던스 개선 기대가 반영되어 실적 점수는 +8로 해석됩니다.',
      ),
      EvidenceItem(
        title: 'AI 최종 의견',
        body: '현재 구간은 장기 적립을 조금 더 공격적으로 가져갈 수 있는 국면으로 보입니다.',
      ),
    ],
  ),
  RecommendationItem(
    name: 'Amazon',
    ticker: 'AMZN',
    currentAmount: '17,000원',
    recommendedAmount: '17,000원',
    confidence: 76,
    currentHolding: '1.12주',
    startedAt: '2025.09.10',
    memo: '클라우드와 광고 성장 체크',
    score: 68,
    note: '실적 흐름은 견조하지만 추가 과열 신호가 약해 현재 금액 유지가 적절합니다.',
    status: RecommendationStatus.maintain,
    evidence: [
      EvidenceItem(
        title: '주가 분석',
        body: '최근 한 달 주가 흐름은 중립 구간으로 유지되고 있습니다.',
      ),
      EvidenceItem(
        title: '뉴스 분석',
        body: 'AWS와 광고 관련 호재가 있으나, 소비 둔화 우려도 함께 존재합니다.',
      ),
      EvidenceItem(
        title: '기관 수급 분석',
        body: '기관 포지션 변화가 크지 않아 중립으로 평가됩니다.',
      ),
      EvidenceItem(
        title: '밸류에이션 분석',
        body: '현재 밸류에이션은 업종 평균 대비 크게 무리한 수준은 아닙니다.',
      ),
      EvidenceItem(
        title: '실적 분석',
        body: '실적은 견조하나 증액으로 바로 전환할 만큼 강한 서프라이즈는 아닙니다.',
      ),
      EvidenceItem(
        title: 'AI 최종 의견',
        body: '지금은 기존 적립 금액을 유지하며 추가 데이터가 쌓일 때까지 관찰하는 편이 안정적입니다.',
      ),
    ],
  ),
];
