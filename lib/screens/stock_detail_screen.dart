import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../currency/currency_scope.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_news_item.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_section_card.dart';
import '../widgets/evidence_section.dart';
import '../widgets/recommendation_badge.dart';

class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({super.key, required this.item});

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyController = CurrencyScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${item.name} 상세'),
      ),
      body: ListenableBuilder(
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailLogo(ticker: item.ticker, logoUrl: item.logoUrl),
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
                    const SizedBox(height: 18),
                    Text(item.note, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(label: '현재 모으기', value: currentAmount),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: '추천 금액',
                      value: recommendedAmount,
                      accentColor: item.status.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniMetricCard(
                      label: '신뢰도',
                      value: '${item.confidence}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetricCard(label: '점수', value: '${item.score}'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetricCard(
                      label: '보유 수량',
                      value: item.currentHolding,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('추천 근거', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '이 종목의 모으기 금액을 판단한 핵심 근거입니다.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    EvidenceSection(items: item.evidence),
                  ],
                ),
              ),
              if (item.relatedNews.isNotEmpty) ...[
                const SizedBox(height: 14),
                AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('관련 뉴스 분석', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        '감성, 종목 관련성, 최신성, 영향도를 함께 반영한 기사별 분석입니다.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ...item.relatedNews.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key == item.relatedNews.length - 1
                                ? 0
                                : 12,
                          ),
                          child: _RelatedNewsCard(news: entry.value),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('투자 메모', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    _MetaLine(label: '투자 시작일', value: item.startedAt),
                    const SizedBox(height: 8),
                    _MetaLine(
                      label: '사용자 메모',
                      value: item.memo.isEmpty ? '등록된 메모가 없습니다.' : item.memo,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipOval(
        child: Container(
          width: 56,
          height: 56,
          color: Colors.white,
          child: Image.network(
            logoUrl!,
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
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.accentColor,
  });

  final String label;
  final String value;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MaeMojiColors.stroke),
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
              color: accentColor ?? MaeMojiColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MaeMojiColors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: MaeMojiColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: MaeMojiColors.ink,
          ),
        ),
      ],
    );
  }
}

class _RelatedNewsCard extends StatelessWidget {
  const _RelatedNewsCard({required this.news});

  final RecommendationNewsItem news;

  @override
  Widget build(BuildContext context) {
    final sentimentColor = switch (news.sentimentLabel.toUpperCase()) {
      'POSITIVE' => MaeMojiColors.increase,
      'NEGATIVE' => MaeMojiColors.stop,
      _ => MaeMojiColors.inkMuted,
    };
    final sentimentText = switch (news.sentimentLabel.toUpperCase()) {
      'POSITIVE' => '긍정',
      'NEGATIVE' => '부정',
      _ => '중립',
    };
    final impactText = switch (news.impactLevel.toUpperCase()) {
      'HIGH' => '영향 높음',
      'MEDIUM' => '영향 보통',
      _ => '영향 낮음',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            news.headline,
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: MaeMojiColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _NewsChip(
                label: '$sentimentText ${_signed(news.sentimentScore)}',
                color: sentimentColor,
              ),
              _NewsChip(
                label: '관련성 ${news.relevanceScore}',
                color: MaeMojiColors.maintain,
              ),
              _NewsChip(label: impactText, color: MaeMojiColors.inkMuted),
            ],
          ),
          if (news.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              news.summary,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: MaeMojiColors.inkSoft,
              ),
            ),
          ],
          if (news.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '판단 이유',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: MaeMojiColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    news.reason,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  news.sourceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MaeMojiColors.inkMuted,
                  ),
                ),
              ),
              if (news.newsUrl.isNotEmpty)
                TextButton(
                  onPressed: () => _openNews(context, news.newsUrl),
                  child: const Text('원문 보기'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _signed(int value) => value > 0 ? '+$value' : '$value';

  Future<void> _openNews(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('뉴스 링크를 열 수 없습니다.')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('뉴스 링크를 열지 못했습니다.')));
    }
  }
}

class _NewsChip extends StatelessWidget {
  const _NewsChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
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
