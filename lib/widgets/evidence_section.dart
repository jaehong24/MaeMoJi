import 'package:flutter/material.dart';

import '../models/evidence_item.dart';
import '../theme/app_theme.dart';

class EvidenceSection extends StatelessWidget {
  const EvidenceSection({
    super.key,
    required this.items,
  });

  final List<EvidenceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .asMap()
          .entries
          .map(
            (entry) => _EvidenceLine(
              item: entry.value,
              isLast: entry.key == items.length - 1,
            ),
          )
          .toList(),
    );
  }
}

class _EvidenceLine extends StatelessWidget {
  const _EvidenceLine({
    required this.item,
    required this.isLast,
  });

  final EvidenceItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : const Color(0xFFF0E9DD),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: MaeMojiColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: MaeMojiColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
