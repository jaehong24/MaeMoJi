import 'package:flutter/material.dart';

import '../models/recommendation_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/evidence_section.dart';
import '../widgets/recommendation_badge.dart';

/// 기획서에서 가장 중요한 화면으로 언급된 추천 근거 화면입니다.
class RecommendationDetailScreen extends StatelessWidget {
  const RecommendationDetailScreen({
    super.key,
    required this.item,
  });

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${item.name} 근거'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text(
                            item.ticker,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MaeMojiColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RecommendationBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        label: '현재 금액',
                        value: item.currentAmount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricBox(
                        label: '추천 금액',
                        value: item.recommendedAmount,
                        valueColor: item.status.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        label: 'AI 종합 점수',
                        value: '${item.score}점',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricBox(
                        label: '신뢰도',
                        value: '${item.confidence}%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('추천 근거', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '사용자가 "왜 이런 추천이 나왔는지" 바로 이해할 수 있도록 근거를 섹션 단위로 나눠 보여줍니다.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                EvidenceSection(items: item.evidence),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MaeMojiColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor ?? MaeMojiColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
