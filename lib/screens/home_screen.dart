import 'package:flutter/material.dart';

import '../currency/currency_scope.dart';
import '../models/home_recommendation_summary.dart';
import '../models/recommendation_status.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/currency_toggle.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/status_summary_chip.dart';
import 'stock_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.refreshVersion = 0});

  final int refreshVersion;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecommendationService _recommendationService =
      const RecommendationService();
  late Future<HomeRecommendationSummary> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _recommendationService.fetchHomeRecommendations();
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
            CurrencyToggle(controller: currencyController),
          ],
        ),
        const SizedBox(height: 20),
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
                .where((item) => !item.isEtfAnalysisPending)
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
                    padding: const EdgeInsets.only(bottom: 12),
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
      _recommendationsFuture = _recommendationService
          .fetchHomeRecommendations();
    });
  }
}
