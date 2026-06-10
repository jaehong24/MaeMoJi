import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusSummaryChip extends StatelessWidget {
  const StatusSummaryChip({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    this.compact = false,
  });

  final String label;
  final int count;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MaeMojiColors.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 8 : 10,
            height: compact ? 8 : 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 6 : 10),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: MaeMojiColors.ink,
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: MaeMojiColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
