import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/recommendation_status.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/recommendation_card.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final increaseCount = sampleRecommendations
        .where((item) => item.status == RecommendationStatus.increase)
        .length;
    final maintainCount = sampleRecommendations
        .where((item) => item.status == RecommendationStatus.maintain)
        .length;
    final reduceCount = sampleRecommendations
        .where((item) => item.status == RecommendationStatus.reduce)
        .length;
    final stopCount = sampleRecommendations
        .where((item) => item.status == RecommendationStatus.stop)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text('추천', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          '모든 종목의 추천 결과를 한데 모아 보여주는 화면입니다.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...sampleRecommendations.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RecommendationCard(item: item),
          ),
        ),
      ],
    );
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
