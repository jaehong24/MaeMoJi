import 'package:flutter/material.dart';

import '../models/recommendation_status.dart';

class RecommendationBadge extends StatelessWidget {
  const RecommendationBadge({super.key, required this.status});

  final RecommendationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }
}
