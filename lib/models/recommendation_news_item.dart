class RecommendationNewsItem {
  const RecommendationNewsItem({
    required this.headline,
    required this.summary,
    required this.sourceName,
    required this.newsUrl,
    required this.sentimentLabel,
    required this.sentimentScore,
    required this.relevanceScore,
    required this.impactLevel,
    required this.reason,
    required this.weightedScore,
  });

  final String headline;
  final String summary;
  final String sourceName;
  final String newsUrl;
  final String sentimentLabel;
  final int sentimentScore;
  final int relevanceScore;
  final String impactLevel;
  final String reason;
  final double weightedScore;
}
