import 'package:flutter/material.dart';

import '../models/recommendation_item.dart';
import '../theme/app_theme.dart';
import '../utils/recommendation_headline_resolver.dart';

class RecommendationReasonChip extends StatelessWidget {
  const RecommendationReasonChip({
    super.key,
    required this.item,
    this.compact = false,
    this.showDescription = true,
  });

  final RecommendationItem item;
  final bool compact;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final headline = resolveRecommendationHeadline(item);
    final tone = _headlineTone(headline.semanticKey);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: tone.$1,
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(color: tone.$2),
      ),
      child: Row(
        children: [
          Text(
            headline.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: tone.$3,
            ),
          ),
          if (showDescription) ...[
            SizedBox(width: compact ? 6 : 8),
            Expanded(
              child: Text(
                _headlineDescription(headline.label),
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: MaeMojiColors.inkMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  (Color, Color, Color) _headlineTone(String semanticKey) {
    switch (semanticKey) {
      case 'price_reflected':
        return (
          const Color(0xFFF6F1E5),
          const Color(0xFFE6D7BA),
          const Color(0xFF8E6C25),
        );
      case 'price_burden':
        return (
          const Color(0xFFF9EEE7),
          const Color(0xFFEAC9B7),
          const Color(0xFFAA5A3B),
        );
      case 'growth_check':
        return (
          const Color(0xFFF1F4E9),
          const Color(0xFFD8E0C6),
          const Color(0xFF5D7133),
        );
      case 'growth_slowdown':
        return (
          const Color(0xFFF4EFE4),
          const Color(0xFFE2D3B7),
          const Color(0xFF8B6A2E),
        );
      case 'volatility':
      case 'risk_control':
        return (
          const Color(0xFFF9ECE9),
          const Color(0xFFE8C5BA),
          const Color(0xFF9E4B36),
        );
      case 'data_gap':
        return (
          const Color(0xFFF1F1EF),
          const Color(0xFFDDDDD8),
          const Color(0xFF6A6A61),
        );
      case 'defensive':
        return (
          const Color(0xFFEEF4F0),
          const Color(0xFFCFE0D4),
          const Color(0xFF4C7760),
        );
      case 'increase':
        return (
          const Color(0xFFECF8F0),
          const Color(0xFFC8E7D1),
          const Color(0xFF268955),
        );
      default:
        return (
          MaeMojiColors.paperSoft,
          MaeMojiColors.stroke,
          MaeMojiColors.ink,
        );
    }
  }

  String _headlineDescription(String label) {
    switch (label) {
      case '가격 반영':
        return '좋은 흐름이 이미 가격에 꽤 반영된 구간이에요.';
      case '가격 부담':
        return '현재 가격 메리트가 낮아 더 보수적으로 보고 있어요.';
      case '성장 확인':
        return '기본 체력은 괜찮지만 한 단계 더 확인이 필요해요.';
      case '성장 둔화':
        return '성장 속도나 재가속 신호가 약해 감액 쪽으로 봤어요.';
      case '변동성':
        return '최근 흔들림과 하방 리스크를 더 크게 반영했어요.';
      case '데이터 부족':
        return '핵심 지표가 더 쌓여야 판단 정확도가 올라가요.';
      case '방어형':
        return '방어 성격은 좋지만 공격적으로 늘릴 구간은 아니에요.';
      case '위험 관리':
        return '지금은 수익보다 리스크 관리가 우선인 구간이에요.';
      case '증액 우세':
        return '핵심 팩터가 고르게 강해 한 단계 더 모아볼 수 있어요.';
      default:
        return '지금 판단의 이유 축을 짧게 정리했어요.';
    }
  }
}
