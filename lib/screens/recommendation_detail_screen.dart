import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../currency/currency_scope.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_news_item.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_section_card.dart';
import '../widgets/evidence_section.dart';
import '../widgets/recommendation_badge.dart';

class RecommendationDetailScreen extends StatelessWidget {
  const RecommendationDetailScreen({
    super.key,
    required this.item,
  });

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyController = CurrencyScope.of(context);

    return ListenableBuilder(
      listenable: currencyController,
      builder: (context, _) {
        final currentAmount = CurrencyFormatter.formatAmount(
          usdAmount: item.currentAmountUsd,
          currency: currencyController.displayCurrency,
          usdToKrwRate: currencyController.usdToKrwRate,
        );
        final recommendedAmount = CurrencyFormatter.formatAmount(
          usdAmount: item.recommendedAmountUsd,
          currency: currencyController.displayCurrency,
          usdToKrwRate: currencyController.usdToKrwRate,
        );

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('${item.name} 상세'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailLogo(
                              ticker: item.ticker,
                              logoUrl: item.logoUrl,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.ticker,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: MaeMojiColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            RecommendationBadge(status: item.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _MetricGrid(
                          currentAmount: currentAmount,
                          recommendedAmount: recommendedAmount,
                          score: item.score,
                          confidence: item.confidence,
                          statusColor: item.status.color,
                        ),
                        if (item.memo.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            item.memo,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('추천 근거', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          '매일 모으기 금액을 이렇게 계산한 이유를 한눈에 볼 수 있어요.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        EvidenceSection(items: item.evidence),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '관련 뉴스',
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            if (item.newsAnalyzedAt != null)
                              Text(
                                '최신 반영 ${_formatDateTime(item.newsAnalyzedAt!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: MaeMojiColors.inkMuted,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.relatedNews.isEmpty
                              ? (item.relatedNewsStatusMessage ??
                                  '관련 뉴스가 아직 없어요.')
                              : '관련성, 감성, 영향도 기준으로 최근 뉴스만 보여드려요.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (item.relatedNews.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...item.relatedNews.asMap().entries.map((entry) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    entry.key == item.relatedNews.length - 1
                                        ? 0
                                        : 12,
                              ),
                              child: _RelatedNewsCard(news: entry.value),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.currentAmount,
    required this.recommendedAmount,
    required this.score,
    required this.confidence,
    required this.statusColor,
  });

  final String currentAmount;
  final String recommendedAmount;
  final int score;
  final int confidence;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final itemWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        final boxes = <Widget>[
          SizedBox(
            width: itemWidth,
            child: _MetricBox(
              label: '현재 매일 모으기',
              value: currentAmount,
            ),
          ),
          SizedBox(
            width: itemWidth,
            child: _MetricBox(
              label: '추천 금액',
              value: recommendedAmount,
              valueColor: statusColor,
            ),
          ),
          SizedBox(
            width: itemWidth,
            child: _MetricBox(
              label: 'AI 점수',
              value: '$score점',
            ),
          ),
          SizedBox(
            width: itemWidth,
            child: _MetricBox(
              label: '신뢰도',
              value: '$confidence%',
            ),
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: boxes,
        );
      },
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MaeMojiColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? MaeMojiColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedNewsCard extends StatelessWidget {
  const _RelatedNewsCard({required this.news});

  final RecommendationNewsItem news;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sentimentColor = switch (news.sentimentLabel.toUpperCase()) {
      'POSITIVE' => MaeMojiColors.increase,
      'NEGATIVE' => MaeMojiColors.stop,
      _ => MaeMojiColors.inkMuted,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MaeMojiColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  news.headline,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _NewsChip(
                label: news.sentimentLabel,
                color: sentimentColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            news.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: MaeMojiColors.inkSoft,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NewsChip(
                label: news.sourceName,
                color: MaeMojiColors.inkMuted,
              ),
              _NewsChip(
                label: '관련성 ${news.relevanceScore}%',
                color: MaeMojiColors.reduce,
              ),
              _NewsChip(
                label: '영향 ${news.impactLevel}',
                color: MaeMojiColors.maintain,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            news.reason,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: MaeMojiColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _openUrl(news.newsUrl),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('원문 보기'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _NewsChip extends StatelessWidget {
  const _NewsChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _DetailLogo extends StatelessWidget {
  const _DetailLogo({required this.ticker, this.logoUrl});

  final String ticker;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final shortTicker = ticker.length > 3 ? ticker.substring(0, 3) : ticker;
    final resolvedLogoUrl = ApiConfig.resolveLogoUrl(
      logoUrl,
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );

    if (resolvedLogoUrl.isNotEmpty) {
      return ClipOval(
        child: Container(
          width: 56,
          height: 56,
          color: Colors.white,
          child: Image.network(
            resolvedLogoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _DetailFallbackLogo(shortTicker: shortTicker);
            },
          ),
        ),
      );
    }

    return _DetailFallbackLogo(shortTicker: shortTicker);
  }
}

class _DetailFallbackLogo extends StatelessWidget {
  const _DetailFallbackLogo({required this.shortTicker});

  final String shortTicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF21295C),
      ),
      alignment: Alignment.center,
      child: Text(
        shortTicker,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
