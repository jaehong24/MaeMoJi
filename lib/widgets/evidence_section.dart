import 'dart:convert';

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
          if (item.evidenceType == 'FACTOR_FUNDAMENTAL_QUALITY') ...[
            const SizedBox(height: 12),
            _FundamentalMetricStrip(rawDataJson: item.rawDataJson),
          ],
        ],
      ),
    );
  }
}

class _FundamentalMetricStrip extends StatelessWidget {
  const _FundamentalMetricStrip({required this.rawDataJson});

  final String? rawDataJson;

  @override
  Widget build(BuildContext context) {
    final metrics = _buildMetrics(rawDataJson);
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: metrics
          .map(
            (metric) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F1E4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: MaeMojiColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                  if (metric.caption != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      metric.caption!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: MaeMojiColors.inkSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  List<_FundamentalMetricChip> _buildMetrics(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const [];
      }

      final metrics = <_FundamentalMetricChip>[
        if (decoded['epsTtm'] is num)
          _FundamentalMetricChip(
            label: 'EPS',
            value: (decoded['epsTtm'] as num).toStringAsFixed(2),
            caption: _bandLabel(decoded['epsBand']?.toString()),
          ),
        if (decoded['revenueGrowthYoy'] is num)
          _FundamentalMetricChip(
            label: '매출 성장',
            value: _formatPercent(decoded['revenueGrowthYoy'] as num),
            caption: _bandLabel(decoded['revenueGrowthBand']?.toString()),
          ),
        if (decoded['operatingMarginTtm'] is num)
          _FundamentalMetricChip(
            label: '영업이익률',
            value: _formatPercent(decoded['operatingMarginTtm'] as num),
            caption: _bandLabel(decoded['operatingMarginBand']?.toString()),
          ),
        if (decoded['roeTtm'] is num)
          _FundamentalMetricChip(
            label: 'ROE',
            value: _formatPercent(decoded['roeTtm'] as num),
            caption: _bandLabel(decoded['roeBand']?.toString()),
          ),
        if (decoded['debtToEquityTtm'] is num)
          _FundamentalMetricChip(
            label: '부채비율',
            value: (decoded['debtToEquityTtm'] as num).toStringAsFixed(2),
            caption: _bandLabel(decoded['debtToEquityBand']?.toString()),
          ),
      ];

      return metrics;
    } catch (_) {
      return const [];
    }
  }

  String _formatPercent(num value) {
    final percent = value * 100;
    final prefix = percent > 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(1)}%';
  }

  String? _bandLabel(String? band) {
    switch ((band ?? '').toUpperCase()) {
      case 'POSITIVE':
        return '양호';
      case 'NEGATIVE':
        return '주의';
      case 'STRONG':
        return '강함';
      case 'EXCEPTIONAL':
        return '매우강함';
      case 'HEALTHY':
        return '양호';
      case 'FLAT':
        return '보통';
      case 'WEAK':
        return '점검';
      case 'CONSERVATIVE':
        return '안정';
      case 'BALANCED':
        return '무난';
      case 'STRETCHED':
        return '주의';
      case 'EXCESSIVE':
        return '위험';
      case 'FAIR':
        return '무난';
      case 'ATTRACTIVE':
        return '매력적';
      case 'EXPENSIVE':
        return '높음';
      case 'VERY_EXPENSIVE':
        return '부담';
      default:
        return null;
    }
  }
}

class _FundamentalMetricChip {
  const _FundamentalMetricChip({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;
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
