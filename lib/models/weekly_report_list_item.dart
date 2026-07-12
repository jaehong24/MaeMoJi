class WeeklyReportListItem {
  const WeeklyReportListItem({
    required this.reportId,
    required this.reportWeek,
    required this.generatedAt,
    required this.headline,
    required this.changedItemCount,
    required this.alertItemCount,
  });

  final int reportId;
  final DateTime? reportWeek;
  final DateTime? generatedAt;
  final String headline;
  final int changedItemCount;
  final int alertItemCount;
}
