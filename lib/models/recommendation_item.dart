import 'evidence_item.dart';
import 'recommendation_status.dart';

/// 추천 카드와 근거 화면에서 함께 사용하는 핵심 도메인 모델입니다.
class RecommendationItem {
  const RecommendationItem({
    required this.name,
    required this.ticker,
    required this.currentAmount,
    required this.recommendedAmount,
    required this.confidence,
    required this.currentHolding,
    required this.startedAt,
    required this.memo,
    required this.score,
    required this.note,
    required this.status,
    required this.evidence,
  });

  final String name;
  final String ticker;
  final String currentAmount;
  final String recommendedAmount;
  final int confidence;
  final String currentHolding;
  final String startedAt;
  final String memo;
  final int score;
  final String note;
  final RecommendationStatus status;
  final List<EvidenceItem> evidence;
}
