import 'recommendation_status.dart';

class RecommendationHistoryItem {
  const RecommendationHistoryItem({
    required this.recommendationId,
    required this.recommendationDate,
    required this.generatedAt,
    required this.status,
    required this.previousStatus,
    required this.score,
    required this.previousScore,
    required this.scoreDelta,
    required this.changeType,
    required this.headline,
    required this.summary,
  });

  final int recommendationId;
  final DateTime? recommendationDate;
  final DateTime? generatedAt;
  final RecommendationStatus status;
  final RecommendationStatus? previousStatus;
  final int score;
  final int? previousScore;
  final int scoreDelta;
  final String changeType;
  final String headline;
  final String summary;
}
