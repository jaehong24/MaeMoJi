import 'package:flutter/material.dart';

import '../currency/currency_scope.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_status.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/currency_toggle.dart';
import '../widgets/recommendation_card.dart';
import 'stock_detail_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final RecommendationService _recommendationService = const RecommendationService();
  late Future<List<RecommendationItem>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _recommendationService.fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyController = CurrencyScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('추천', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    '등록한 종목의 최신 추천 결과를 한데 모아 보여주는 화면입니다.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CurrencyToggle(controller: currencyController),
          ],
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<RecommendationItem>>(
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
                      '백엔드 서버를 확인하거나 추천을 다시 생성해 주세요.',
                      style: TextStyle(
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reloadRecommendations,
                      child: const Text('추천 다시 생성'),
                    ),
                  ],
                ),
              );
            }

            final recommendations = snapshot.data ?? const [];
            if (recommendations.isEmpty) {
              return const AppSectionCard(
                child: Text(
                  '아직 생성된 추천이 없습니다. 포트폴리오 등록 후 추천을 생성해 주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: MaeMojiColors.inkMuted,
                  ),
                ),
              );
            }

            final scorableRecommendations = recommendations
                .where((item) => !item.isEtfAnalysisPending)
                .toList();
            final pendingEtfCount = recommendations
                .where((item) => item.isEtfAnalysisPending)
                .length;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionCard(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _SummaryPill(
                        label: '증액',
                        count: increaseCount,
                        color: MaeMojiColors.increase,
                      ),
                      _SummaryPill(
                        label: '유지',
                        count: maintainCount,
                        color: MaeMojiColors.maintain,
                      ),
                      _SummaryPill(
                        label: '축소',
                        count: reduceCount,
                        color: MaeMojiColors.reduce,
                      ),
                      _SummaryPill(
                        label: '중단',
                        count: stopCount,
                        color: MaeMojiColors.stop,
                      ),
                      if (pendingEtfCount > 0)
                        _SummaryPill(
                          label: '준비 중',
                          count: pendingEtfCount,
                          color: MaeMojiColors.reduce,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...recommendations.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecommendationCard(
                      item: item,
                      onOpenDetail: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StockDetailScreen(
                              portfolioItemId: item.portfolioItemId,
                              initialItem: item,
                            ),
                          ),
                        );
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
      _recommendationsFuture = _recommendationService.generateRecommendations();
    });
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $count개',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
