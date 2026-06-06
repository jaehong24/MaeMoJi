import 'package:flutter/material.dart';

import '../models/recommendation_item.dart';
import '../theme/app_theme.dart';
import 'app_section_card.dart';
import 'recommendation_badge.dart';

class PortfolioItemCard extends StatelessWidget {
  const PortfolioItemCard({super.key, required this.item});

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.name} · ${item.ticker}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MaeMojiColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text('매일모으기 ${item.currentAmount}'),
                Text('보유 수량 ${item.currentHolding}'),
                Text('투자 시작일 ${item.startedAt}'),
                const SizedBox(height: 8),
                Text(
                  item.memo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: MaeMojiColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          RecommendationBadge(status: item.status),
        ],
      ),
    );
  }
}
