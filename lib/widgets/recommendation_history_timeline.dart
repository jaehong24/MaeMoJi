import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/recommendation_history_item.dart';
import '../theme/app_theme.dart';

class RecommendationHistoryTimeline extends StatelessWidget {
  RecommendationHistoryTimeline({super.key, required this.items});

  final List<RecommendationHistoryItem> items;
  final DateFormat _dateFormat = DateFormat('M월 d일');

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(5).toList();
    if (visibleItems.length <= 1) {
      return Text(
        '아직 비교할 추천 변화가 없어요.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children: visibleItems.map((item) {
        final isLast = item == visibleItems.last;
        return _TimelineRow(
          item: item,
          dateLabel: _dateLabel(item),
          isLast: isLast,
        );
      }).toList(),
    );
  }

  String _dateLabel(RecommendationHistoryItem item) {
    final value = item.recommendationDate ?? item.generatedAt;
    return value == null ? '최근' : _dateFormat.format(value.toLocal());
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.dateLabel,
    required this.isLast,
  });

  final RecommendationHistoryItem item;
  final String dateLabel;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = item.status.color;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: MaeMojiColors.stroke,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MaeMojiColors.inkMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.status.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _scoreLabel(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MaeMojiColors.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.headline, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    item.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.45,
                      color: MaeMojiColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _scoreLabel() {
    if (item.previousScore == null || item.scoreDelta == 0) {
      return '${item.score}점';
    }
    final sign = item.scoreDelta > 0 ? '+' : '';
    return '${item.score}점 ($sign${item.scoreDelta})';
  }
}
