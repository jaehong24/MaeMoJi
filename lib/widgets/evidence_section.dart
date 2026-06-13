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
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EvidenceCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.item});

  final EvidenceItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF0E9DD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: MaeMojiColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: MaeMojiColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
