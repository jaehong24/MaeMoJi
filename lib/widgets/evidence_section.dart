import 'package:flutter/material.dart';

import '../models/evidence_item.dart';
import '../theme/app_theme.dart';

class EvidenceSection extends StatelessWidget {
  const EvidenceSection({super.key, required this.items});

  final List<EvidenceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 10),
          child: _EvidenceCard(item: item),
        );
      }),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.item});

  final EvidenceItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E9DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MaeMojiColors.ink,
            ),
          ),
          const SizedBox(height: 8),
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
