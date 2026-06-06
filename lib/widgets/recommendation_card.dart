import 'package:flutter/material.dart';

import '../models/recommendation_item.dart';
import '../screens/recommendation_detail_screen.dart';
import '../theme/app_theme.dart';
import 'app_section_card.dart';
import 'recommendation_badge.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.item,
    this.showMemo = true,
  });

  final RecommendationItem item;
  final bool showMemo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: theme.textTheme.titleLarge),
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
                child: _AmountBlock(
                  label: '현재 매일모으기',
                  amount: item.currentAmount,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountBlock(
                  label: '추천 금액',
                  amount: item.recommendedAmount,
                  emphasisColor: item.status.color,
                ),
              ),
            ],
          ),
          if (showMemo) ...[
            const SizedBox(height: 18),
            Text(item.note, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '신뢰도 ${item.confidence}% · 점수 ${item.score}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MaeMojiColors.inkMuted,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RecommendationDetailScreen(item: item),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('근거 보기'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({
    required this.label,
    required this.amount,
    this.emphasisColor,
  });

  final String label;
  final String amount;
  final Color? emphasisColor;

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
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: emphasisColor ?? MaeMojiColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
