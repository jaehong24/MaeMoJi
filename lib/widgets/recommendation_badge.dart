import 'package:flutter/material.dart';

import '../models/recommendation_status.dart';

class RecommendationBadge extends StatelessWidget {
  const RecommendationBadge({
    super.key,
    required this.status,
    this.labelOverride,
    this.colorOverride,
  });

  final RecommendationStatus status;
  final String? labelOverride;
  final Color? colorOverride;

  @override
  Widget build(BuildContext context) {
    final color = colorOverride ?? status.color;
    final label = labelOverride ?? status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
