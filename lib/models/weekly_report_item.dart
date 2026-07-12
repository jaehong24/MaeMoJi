class WeeklyReportItem {
  const WeeklyReportItem({
    required this.portfolioItemId,
    required this.stockId,
    required this.companyName,
    required this.ticker,
    required this.logoUrl,
    required this.currentStatus,
    required this.previousStatus,
    required this.scoreDelta,
    required this.headlineLabel,
    required this.changeType,
    required this.summary,
  });

  final int portfolioItemId;
  final int stockId;
  final String companyName;
  final String ticker;
  final String? logoUrl;
  final String currentStatus;
  final String previousStatus;
  final int scoreDelta;
  final String headlineLabel;
  final String changeType;
  final String summary;
}
