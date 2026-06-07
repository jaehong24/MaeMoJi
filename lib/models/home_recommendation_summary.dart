import 'recommendation_item.dart';

class HomeRecommendationSummary {
  const HomeRecommendationSummary({
    required this.calculatedAt,
    required this.priceDataDate,
    required this.newsAnalyzedAt,
    required this.items,
  });

  final DateTime? calculatedAt;
  final DateTime? priceDataDate;
  final DateTime? newsAnalyzedAt;
  final List<RecommendationItem> items;
}
