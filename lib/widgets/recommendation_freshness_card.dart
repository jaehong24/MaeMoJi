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
              Expanded(
                child: Text(
                  _buildHeadline(summary),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MaeMojiColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _buildDescription(summary),
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: MaeMojiColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              _DataStamp(
                label: '추천 확인',
                value: summary.recommendationGeneratedAt == null
                    ? '준비 중'
                    : _formatDateTime(summary.recommendationGeneratedAt),
              ),
              _DataStamp(
                label: '가격 기준',
                value: summary.priceDataDate == null
                    ? '준비 중'
                    : '${_formatDate(summary.priceDataDate)} 미국장 마감',
              ),
              _DataStamp(
                label: '뉴스 확인',
                value: summary.newsAnalyzedAt == null
                    ? '준비 중'
                    : _formatDateTime(summary.newsAnalyzedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _buildHeadline(HomeRecommendationSummary summary) {
    final generatedAt = summary.recommendationGeneratedAt?.toLocal();
    if (generatedAt == null) {
      return '추천을 준비하고 있어요';
    }
    if (_isToday(generatedAt)) {
      return '오늘 다시 확인한 추천이에요';
    }
    if (_isYesterday(generatedAt)) {
      return '어제 저장된 추천을 보고 있어요';
    }
    return '최근 저장된 추천을 보고 있어요';
  }

  static String _buildDescription(HomeRecommendationSummary summary) {
    final refreshedAt = summary.calculatedAt?.toLocal();
    if (refreshedAt == null) {
      return '화면에 보이는 추천과 기준 시각을 정리하고 있어요.';
    }
    return '화면은 ${_formatDateTime(refreshedAt)}에 새로 고침했어요.';
  }

  static String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    final local = value.toLocal();
    return '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '준비 중';
    }
    final local = value.toLocal();
    final period = local.hour < 12 ? '오전' : '오후';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.month}/${local.day} $period $hour:$minute';
  }

  static bool _isToday(DateTime value) {
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }

  static bool _isYesterday(DateTime value) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return value.year == yesterday.year &&
        value.month == yesterday.month &&
        value.day == yesterday.day;
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
