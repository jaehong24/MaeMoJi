import 'weekly_report_item.dart';

class WeeklyReport {
  const WeeklyReport({
    required this.reportId,
    required this.reportWeek,
    required this.generatedAt,
    required this.headline,
    required this.summary,
    required this.changedItemCount,
    required this.alertItemCount,
    required this.positiveItemCount,
    required this.negativeItemCount,
    required this.items,
  });

  final int reportId;
  final DateTime? reportWeek;
  final DateTime? generatedAt;
  final String headline;
  final String summary;
  final int changedItemCount;
  final int alertItemCount;
  final int positiveItemCount;
  final int negativeItemCount;
  final List<WeeklyReportItem> items;
}
