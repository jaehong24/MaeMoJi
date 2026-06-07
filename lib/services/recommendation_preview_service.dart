import '../models/evidence_item.dart';
import '../models/portfolio_item_summary.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_status.dart';

class RecommendationPreviewService {
  const RecommendationPreviewService();

  List<RecommendationItem> buildFromPortfolio(List<PortfolioItemSummary> items) {
    return items.map(_toRecommendationItem).toList();
  }

  RecommendationItem _toRecommendationItem(PortfolioItemSummary item) {
    final currentAmountUsd = double.tryParse(item.dailyInvestAmount) ?? 0;
    final status = _resolveStatus(item.stockId);
    final recommendedAmountUsd = _resolveRecommendedAmount(
      currentAmountUsd: currentAmountUsd,
      status: status,
    );

    return RecommendationItem(
      name: item.companyName,
      ticker: item.ticker,
      logoUrl: item.logoUrl,
      currentAmountUsd: currentAmountUsd,
      recommendedAmountUsd: recommendedAmountUsd,
      confidence: _resolveConfidence(item.stockId),
      currentHolding: item.holdingQuantity.isEmpty ? '-' : '${item.holdingQuantity}주',
      startedAt: item.investmentStartDate.isEmpty ? '-' : item.investmentStartDate,
      memo: item.memo,
      score: _resolveScore(item.stockId),
      note: _buildNote(item, status),
      status: status,
      evidence: _buildEvidence(item, currentAmountUsd, recommendedAmountUsd, status),
      relatedNews: const [],
    );
  }

  RecommendationStatus _resolveStatus(int stockId) {
    switch (stockId % 4) {
      case 0:
        return RecommendationStatus.increase;
      case 1:
        return RecommendationStatus.maintain;
      case 2:
        return RecommendationStatus.reduce;
      default:
        return RecommendationStatus.maintain;
    }
  }

  double _resolveRecommendedAmount({
    required double currentAmountUsd,
    required RecommendationStatus status,
  }) {
    switch (status) {
      case RecommendationStatus.increase:
        return double.parse((currentAmountUsd * 1.2).toStringAsFixed(2));
      case RecommendationStatus.maintain:
        return double.parse(currentAmountUsd.toStringAsFixed(2));
      case RecommendationStatus.reduce:
        return double.parse((currentAmountUsd * 0.8).toStringAsFixed(2));
      case RecommendationStatus.stop:
        return 0;
    }
  }

  int _resolveConfidence(int stockId) => 68 + (stockId % 5) * 4;

  int _resolveScore(int stockId) => 55 + (stockId % 5) * 6;

  String _buildNote(PortfolioItemSummary item, RecommendationStatus status) {
    switch (status) {
      case RecommendationStatus.increase:
        return '${item.companyName}은 현재 적립 흐름보다 조금 더 공격적으로 가져갈 만한 종목으로 정리했습니다.';
      case RecommendationStatus.maintain:
        return '${item.companyName}은 현재 적립 금액을 유지하면서 흐름을 지켜보는 전략이 적절합니다.';
      case RecommendationStatus.reduce:
        return '${item.companyName}은 현재 적립 금액을 조금 줄이고 관찰 비중을 높이는 쪽이 안정적입니다.';
      case RecommendationStatus.stop:
        return '${item.companyName}은 신규 적립을 멈추고 재점검이 필요한 상태로 분류했습니다.';
    }
  }

  List<EvidenceItem> _buildEvidence(
    PortfolioItemSummary item,
    double currentAmountUsd,
    double recommendedAmountUsd,
    RecommendationStatus status,
  ) {
    return [
      EvidenceItem(
        title: '등록 금액 기준',
        body: '현재 매일 모으기 금액은 \$${currentAmountUsd.toStringAsFixed(2)}로 등록되어 있습니다.',
      ),
      EvidenceItem(
        title: '추천 조정 결과',
        body: '현재 상태는 ${status.label}이며 추천 금액은 \$${recommendedAmountUsd.toStringAsFixed(2)}입니다.',
      ),
      EvidenceItem(
        title: '투자 시작일 참고',
        body: item.investmentStartDate.isEmpty
            ? '아직 투자 시작일이 없어 보수적으로 해석했습니다.'
            : '투자 시작일 ${item.investmentStartDate} 기준으로 장기 적립 흐름을 반영했습니다.',
      ),
      EvidenceItem(
        title: '메모 반영',
        body: item.memo.isEmpty
            ? '등록 메모가 없어 기본 규칙 기준으로 추천을 구성했습니다.'
            : '등록 메모 "${item.memo}"를 참고해 설명 문구를 보강했습니다.',
      ),
    ];
  }
}
