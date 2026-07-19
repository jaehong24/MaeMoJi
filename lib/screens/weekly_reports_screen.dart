import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weekly_report.dart';
import '../models/weekly_report_item.dart';
import '../models/weekly_report_list_item.dart';
import '../services/portfolio_insight_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import 'stock_detail_screen.dart';

class WeeklyReportsScreen extends StatefulWidget {
  const WeeklyReportsScreen({super.key});

  @override
  State<WeeklyReportsScreen> createState() => _WeeklyReportsScreenState();
}

class _WeeklyReportsScreenState extends State<WeeklyReportsScreen> {
  final PortfolioInsightService _portfolioInsightService =
      const PortfolioInsightService();
  final DateFormat _weekFormat = DateFormat('yyyy년 M월 d일');
  final DateFormat _generatedFormat = DateFormat('M월 d일 HH:mm');

  late Future<_WeeklyReportsBundle> _bundleFuture;

  @override
  void initState() {
    super.initState();
    _bundleFuture = _loadBundle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('주간 리포트'),
      ),
      body: FutureBuilder<_WeeklyReportsBundle>(
        future: _bundleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AppSectionCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주간 리포트를 불러오지 못했어요.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('잠시 후 다시 시도해 주세요.', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reload,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bundle = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                if (bundle.latest != null) ...[
                  _LatestWeeklyReportCard(
                    report: bundle.latest!,
                    weekFormat: _weekFormat,
                    generatedFormat: _generatedFormat,
                    onOpenItem: _openItemDetail,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  '지난 리포트',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (bundle.history.isEmpty)
                  AppSectionCard(
                    child: Text(
                      '아직 쌓인 리포트가 없어요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                else
                  ...bundle.history.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _WeeklyHistoryCard(
                        item: item,
                        weekFormat: _weekFormat,
                        generatedFormat: _generatedFormat,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_WeeklyReportsBundle> _loadBundle() async {
    final latest = await _portfolioInsightService.fetchLatestWeeklyReport();
    final history = await _portfolioInsightService.fetchWeeklyReports();
    final filteredHistory = latest == null
        ? history
        : history.where((item) => item.reportId != latest.reportId).toList();
    return _WeeklyReportsBundle(latest: latest, history: filteredHistory);
  }

  Future<void> _refresh() async {
    final bundle = await _loadBundle();
    if (!mounted) {
      return;
    }
    setState(() {
      _bundleFuture = Future<_WeeklyReportsBundle>.value(bundle);
    });
  }

  void _reload() {
    setState(() {
      _bundleFuture = _loadBundle();
    });
  }

  Future<void> _openItemDetail(WeeklyReportItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(
          portfolioItemId: item.portfolioItemId,
          initialFocusSection: _focusSectionForChangeType(item.changeType),
        ),
      ),
    );
    if (mounted) {
      _reload();
    }
  }

  StockDetailFocusSection _focusSectionForChangeType(String changeType) {
    switch (changeType.toUpperCase()) {
      case 'NEWS_WEAKENED':
      case 'NEWS_IMPROVED':
        return StockDetailFocusSection.news;
      default:
        return StockDetailFocusSection.history;
    }
  }
}

class _LatestWeeklyReportCard extends StatelessWidget {
  const _LatestWeeklyReportCard({
    required this.report,
    required this.weekFormat,
    required this.generatedFormat,
    required this.onOpenItem,
  });

  final WeeklyReport report;
  final DateFormat weekFormat;
  final DateFormat generatedFormat;
  final ValueChanged<WeeklyReportItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightedItems = report.items.take(5).toList();
    final remainingItemCount = report.items.length - highlightedItems.length;

    return AppSectionCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 리포트',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            report.reportWeek == null
                ? report.headline
                : '${weekFormat.format(report.reportWeek!.toLocal())} 기준',
            style: theme.textTheme.bodySmall?.copyWith(
              color: MaeMojiColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            report.headline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: MaeMojiColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(report.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniInfoChip(label: '변화', value: '${report.changedItemCount}개'),
              _MiniInfoChip(label: '알림', value: '${report.alertItemCount}건'),
              _MiniInfoChip(label: '긍정', value: '${report.positiveItemCount}개'),
              _MiniInfoChip(label: '주의', value: '${report.negativeItemCount}개'),
            ],
          ),
          if (report.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              '중요 변화',
              style: theme.textTheme.bodySmall?.copyWith(
                color: MaeMojiColors.inkMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...highlightedItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onOpenItem(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.companyName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: MaeMojiColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.supplementalPriceRisk) ...[
                                const SizedBox(height: 5),
                                const _SupplementalPriceRiskInlineChip(),
                              ],
                              const SizedBox(height: 3),
                              Text(
                                item.summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: MaeMojiColors.inkSoft,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
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
                            _weeklyChangeLabel(item),
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
            if (remainingItemCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '그 밖의 변화 $remainingItemCount개도 이번 주 요약에 함께 반영했어요.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MaeMojiColors.inkMuted,
                  ),
                ),
              ),
          ],
          if (report.generatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              '${generatedFormat.format(report.generatedAt!.toLocal())} 생성',
              style: theme.textTheme.bodySmall?.copyWith(
                color: MaeMojiColors.inkMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _weeklyChangeLabel(WeeklyReportItem item) {
  switch (item.changeType.toUpperCase()) {
    case 'PRICE_RISK':
      return '가격 위험';
    case 'NEWS_WEAKENED':
      return '뉴스 악화';
    case 'STATUS_DOWNGRADED':
    case 'STATUS_UPGRADED':
    case 'STATUS_REBALANCED':
      return '의견 변경';
    case 'DATA_PENDING':
      return '자료 수집 중';
    case 'NEWS_IMPROVED':
      return '뉴스 개선';
    case 'PRICE_IMPROVED':
      return '가격 안정';
    case 'FUNDAMENTAL_IMPROVED':
      return '기업 체력';
    case 'NEW_ENTRY':
      return '새로 분석';
    default:
      return item.headlineLabel;
  }
}

class _SupplementalPriceRiskInlineChip extends StatelessWidget {
  const _SupplementalPriceRiskInlineChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: MaeMojiColors.maintain.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: MaeMojiColors.maintain.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        '가격 흔들림 동반',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MaeMojiColors.inkSoft,
        ),
      ),
    );
  }
}

class _WeeklyHistoryCard extends StatelessWidget {
  const _WeeklyHistoryCard({
    required this.item,
    required this.weekFormat,
    required this.generatedFormat,
  });

  final WeeklyReportListItem item;
  final DateFormat weekFormat;
  final DateFormat generatedFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSectionCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.reportWeek == null
                ? '지난 리포트'
                : weekFormat.format(item.reportWeek!.toLocal()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: MaeMojiColors.inkMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.headline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MaeMojiColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniInfoChip(label: '변화', value: '${item.changedItemCount}개'),
              _MiniInfoChip(label: '알림', value: '${item.alertItemCount}건'),
            ],
          ),
          if (item.generatedAt != null) ...[
            const SizedBox(height: 10),
            Text(
              '${generatedFormat.format(item.generatedAt!.toLocal())} 생성',
              style: theme.textTheme.bodySmall?.copyWith(
                color: MaeMojiColors.inkMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(14),
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
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyReportsBundle {
  const _WeeklyReportsBundle({required this.latest, required this.history});

  final WeeklyReport? latest;
  final List<WeeklyReportListItem> history;
}
