import 'package:flutter/material.dart';

import '../models/home_recommendation_summary.dart';
import '../theme/app_theme.dart';

class RecommendationFreshnessCard extends StatelessWidget {
  const RecommendationFreshnessCard({super.key, required this.summary});

  final HomeRecommendationSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MaeMojiColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: MaeMojiColors.maintain,
              ),
              const SizedBox(width: 7),
              Text(
                '${_formatDateTime(summary.calculatedAt)} 기준',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MaeMojiColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              _DataStamp(
                label: '가격',
                value: summary.priceDataDate == null
                    ? '준비 중'
                    : '${_formatDate(summary.priceDataDate)} 저장',
              ),
              _DataStamp(
                label: '뉴스',
                value: summary.newsAnalyzedAt == null
                    ? '분석 전'
                    : _formatDateTime(summary.newsAnalyzedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    final local = value.toLocal();
    return '${local.month}월 ${local.day}일';
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '계산 전';
    }
    final local = value.toLocal();
    final period = local.hour < 12 ? '오전' : '오후';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.month}월 ${local.day}일 $period $hour:$minute';
  }
}

class _DataStamp extends StatelessWidget {
  const _DataStamp({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: MaeMojiColors.ink,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: MaeMojiColors.inkMuted),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}
