import 'package:flutter/material.dart';

import '../models/evidence_item.dart';
import '../theme/app_theme.dart';

class EvidenceSection extends StatelessWidget {
  const EvidenceSection({
    super.key,
    required this.items,
    this.riskProfileLabel,
  });

  final List<EvidenceItem> items;
  final String? riskProfileLabel;

  @override
  Widget build(BuildContext context) {
    final rawFactorItems = items
        .where((item) => item.isFactor)
        .toList()
      ..sort((left, right) {
        final leftOrder = left.displayOrder ?? 999;
        final rightOrder = right.displayOrder ?? 999;
        return leftOrder.compareTo(rightOrder);
      });
    final userFitItem = rawFactorItems
        .where((item) => item.evidenceType == 'FACTOR_USER_FIT')
        .firstOrNull;
    final factorItems = [
      ?userFitItem,
      ...rawFactorItems.where((item) => item.evidenceType != 'FACTOR_USER_FIT'),
    ];
    final noteItem = items.where((item) => item.isAiNote).firstOrNull;
    final extraItems = items
        .where((item) => !item.isFactor && !item.isAiNote)
        .toList()
      ..sort((left, right) {
        final leftOrder = left.displayOrder ?? 999;
        final rightOrder = right.displayOrder ?? 999;
        return leftOrder.compareTo(rightOrder);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (factorItems.isNotEmpty)
          _FactorGrid(
            items: factorItems,
            riskProfileLabel: riskProfileLabel,
          ),
        if (noteItem != null) ...[
          if (factorItems.isNotEmpty) const SizedBox(height: 12),
          _AiNoteCard(item: noteItem),
        ],
        if (extraItems.isNotEmpty) ...[
          if (factorItems.isNotEmpty || noteItem != null) const SizedBox(height: 12),
          ...extraItems.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == extraItems.length - 1 ? 0 : 10,
              ),
              child: _EvidenceCard(item: entry.value),
            );
          }),
        ],
      ],
    );
  }

}

class _FactorGrid extends StatelessWidget {
  const _FactorGrid({
    required this.items,
    required this.riskProfileLabel,
  });

  final List<EvidenceItem> items;
  final String? riskProfileLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final itemWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _FactorCard(
                    item: item,
                    riskProfileLabel: item.evidenceType == 'FACTOR_USER_FIT'
                        ? riskProfileLabel
                        : null,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _FactorCard extends StatelessWidget {
  const _FactorCard({
    required this.item,
    this.riskProfileLabel,
  });

  final EvidenceItem item;
  final String? riskProfileLabel;

  @override
  Widget build(BuildContext context) {
    final score = item.scoreImpact;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DFC9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (riskProfileLabel case final label?)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4E8C8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: MaeMojiColors.inkSoft,
                          ),
                        ),
                      ),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E8C8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$score점',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: MaeMojiColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiNoteCard extends StatelessWidget {
  const _AiNoteCard({required this.item});

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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: MaeMojiColors.increase,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MaeMojiColors.ink,
                ),
              ),
            ],
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
