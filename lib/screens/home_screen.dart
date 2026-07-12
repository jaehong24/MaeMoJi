import 'package:flutter/material.dart';

import '../currency/currency_scope.dart';
import '../models/home_recommendation_summary.dart';
import '../models/recommendation_status.dart';
import '../models/user_alert_event.dart';
import '../models/weekly_report.dart';
import '../services/portfolio_insight_service.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/currency_toggle.dart';
import '../widgets/recent_alerts_preview_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/status_summary_chip.dart';
import '../widgets/unread_badge_icon.dart';
import 'alerts_screen.dart';
import 'stock_detail_screen.dart';
import 'weekly_reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.refreshVersion = 0});

  final int refreshVersion;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecommendationService _recommendationService =
      const RecommendationService();
  final PortfolioInsightService _portfolioInsightService =
      const PortfolioInsightService();
  late Future<HomeRecommendationSummary> _recommendationsFuture;
  late Future<WeeklyReport?> _weeklyReportFuture;
  late Future<List<UserAlertEvent>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _recommendationService.fetchHomeRecommendations();
    _weeklyReportFuture = _portfolioInsightService.fetchLatestWeeklyReport();
    _alertsFuture = _portfolioInsightService.fetchAlerts();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reloadRecommendations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyController = CurrencyScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 매모지',
                    maxLines: 1,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '매일 모으기 흐름을 빠르게 확인해요.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: MaeMojiColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FutureBuilder<List<UserAlertEvent>>(
              future: _alertsFuture,
              builder: (context, snapshot) {
                final unreadCount = (snapshot.data ?? const <UserAlertEvent>[])
                    .where((item) => item.readAt == null)
                    .length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: UnreadBadgeIcon(
                    count: unreadCount,
                    onTap: _openAlerts,
                  ),
                );
              },
            ),
            CurrencyToggle(controller: currencyController),
          ],
        ),
        const SizedBox(height: 20),
        FutureBuilder<WeeklyReport?>(
          future: _weeklyReportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: AppSectionCard(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _WeeklyReportSummaryCard(
                report: snapshot.data!,
                onOpenAll: _openWeeklyReports,
                onOpenItem: _openReportItemDetail,
              ),
            );
          },
        ),
        FutureBuilder<List<UserAlertEvent>>(
          future: _alertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SizedBox.shrink(),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RecentAlertsPreviewCard(
                title: '최근 알림',
                alerts: snapshot.data ?? const [],
                emptyMessage: '아직 바로 확인할 알림은 없어요.',
                onOpenAll: _openAlerts,
                onOpenAlert: _openAlertDetail,
              ),
            );
          },
        ),
        FutureBuilder<HomeRecommendationSummary>(
          future: _recommendationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppSectionCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '추천 결과를 불러오지 못했습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '잠시 후 다시 시도해 주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reloadRecommendations,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              );
            }

            final recommendations = snapshot.data!.items.take(5).toList();
            if (recommendations.isEmpty) {
              return const AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '아직 표시할 종목이 없습니다.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '포트폴리오에 종목을 담으면 이곳에 최대 5개까지 보여드려요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            final scorableRecommendations = recommendations
                .where((item) => !item.isEtfAnalysisPending && !item.isAnalysisPending)
                .toList();
            final increaseCount = scorableRecommendations
                .where((item) => item.status == RecommendationStatus.increase)
                .length;
            final maintainCount = scorableRecommendations
                .where((item) => item.status == RecommendationStatus.maintain)
                .length;
            final reduceCount = scorableRecommendations
                .where((item) => item.status == RecommendationStatus.reduce)
                .length;
            final stopCount = scorableRecommendations
                .where((item) => item.status == RecommendationStatus.stop)
                .length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatusSummaryChip(
                        label: RecommendationStatus.increase.label,
                        count: increaseCount,
                        color: MaeMojiColors.increase,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatusSummaryChip(
                        label: RecommendationStatus.maintain.label,
                        count: maintainCount,
                        color: MaeMojiColors.maintain,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatusSummaryChip(
                        label: RecommendationStatus.reduce.label,
                        count: reduceCount,
                        color: MaeMojiColors.reduce,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatusSummaryChip(
                        label: RecommendationStatus.stop.label,
                        count: stopCount,
                        color: MaeMojiColors.stop,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...recommendations.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RecommendationCard(
                      item: item,
                      compact: true,
                      onOpenDetail: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StockDetailScreen(
                              portfolioItemId: item.portfolioItemId,
                              initialItem: item,
                            ),
                          ),
                        );
                        if (mounted) {
                          _reloadRecommendations();
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _reloadRecommendations() {
    setState(() {
      _recommendationsFuture = _recommendationService.fetchHomeRecommendations();
      _weeklyReportFuture = _portfolioInsightService.fetchLatestWeeklyReport();
      _alertsFuture = _portfolioInsightService.fetchAlerts();
    });
  }

  Future<void> _openAlerts() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AlertsScreen()),
    );
    if (mounted) {
      _reloadRecommendations();
    }
  }

  Future<void> _openAlertDetail(UserAlertEvent alert) async {
    if (alert.readAt == null) {
      try {
        await _portfolioInsightService.markAlertAsRead(alert.alertId);
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(portfolioItemId: alert.portfolioItemId),
      ),
    );

    if (mounted) {
      _reloadRecommendations();
    }
  }

  Future<void> _openWeeklyReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WeeklyReportsScreen()),
    );
    if (mounted) {
      _reloadRecommendations();
    }
  }

  Future<void> _openReportItemDetail(int portfolioItemId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(portfolioItemId: portfolioItemId),
      ),
    );
    if (mounted) {
      _reloadRecommendations();
    }
  }
}

class _WeeklyReportSummaryCard extends StatelessWidget {
  const _WeeklyReportSummaryCard({
    required this.report,
    required this.onOpenAll,
    required this.onOpenItem,
  });

  final WeeklyReport report;
  final VoidCallback onOpenAll;
  final ValueChanged<int> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewItems = report.items.take(2).toList();

    return AppSectionCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '이번 주 매모지 리포트',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (report.generatedAt != null)
                Text(
                  _formatGeneratedDate(report.generatedAt!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MaeMojiColors.inkMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.headline.isEmpty ? '이번 주 변화만 짧게 모아봤어요.' : report.headline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: MaeMojiColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            report.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MaeMojiColors.inkSoft,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _WeeklyMetricChip(label: '변화', value: '${report.changedItemCount}개'),
              _WeeklyMetricChip(label: '알림', value: '${report.alertItemCount}건'),
              _WeeklyMetricChip(label: '긍정', value: '${report.positiveItemCount}개'),
              _WeeklyMetricChip(label: '주의', value: '${report.negativeItemCount}개'),
            ],
          ),
          if (previewItems.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...previewItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onOpenItem(item.portfolioItemId),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.companyName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: MaeMojiColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: MaeMojiColors.paperSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            item.headlineLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: MaeMojiColors.inkSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onOpenAll,
              child: const Text('전체 보기'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGeneratedDate(DateTime value) {
    final local = value.toLocal();
    return '${local.month}.${local.day}';
  }
}

class _WeeklyMetricChip extends StatelessWidget {
  const _WeeklyMetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: MaeMojiColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MaeMojiColors.inkMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MaeMojiColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
