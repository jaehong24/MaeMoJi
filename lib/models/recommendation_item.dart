import 'evidence_item.dart';
import 'recommendation_news_item.dart';
import 'recommendation_status.dart';

class RecommendationItem {
  const RecommendationItem({
    required this.portfolioItemId,
    required this.stockId,
    required this.name,
    required this.ticker,
    required this.logoUrl,
    required this.currentAmountUsd,
    required this.recommendedAmountUsd,
    required this.confidence,
    required this.currentHolding,
    required this.startedAt,
    required this.memo,
    required this.score,
    required this.note,
    required this.status,
    required this.evidence,
    required this.relatedNews,
    required this.recommendationDate,
    required this.recommendationGeneratedAt,
    required this.newsAnalyzedAt,
    required this.relatedNewsStatusMessage,
  });

  final int portfolioItemId;
  final int stockId;
  final String name;
  final String ticker;
  final String? logoUrl;
  final double currentAmountUsd;
  final double recommendedAmountUsd;
  final int confidence;
  final String currentHolding;
  final String startedAt;
  final String memo;
  final int score;
  final String note;
  final RecommendationStatus status;
  final List<EvidenceItem> evidence;
  final List<RecommendationNewsItem> relatedNews;
  final DateTime? recommendationDate;
  final DateTime? recommendationGeneratedAt;
  final DateTime? newsAnalyzedAt;
  final String? relatedNewsStatusMessage;
}
