import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../currency/currency_scope.dart';
import '../models/display_currency.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_news_item.dart';
import '../models/stock_quote.dart';
import '../services/recommendation_service.dart';
import '../services/stock_quote_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_section_card.dart';
import '../widgets/evidence_section.dart';
import '../widgets/recommendation_badge.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({
    super.key,
    required this.portfolioItemId,
    this.initialItem,
  });

  final int portfolioItemId;
  final RecommendationItem? initialItem;

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final RecommendationService _recommendationService =
      const RecommendationService();
  final StockQuoteService _stockQuoteService = const StockQuoteService();
  final DateFormat _quoteTimeFormat = DateFormat('yyyy년 M월 d일 HH:mm');
  final DateFormat _metaTimeFormat = DateFormat('yyyy년 M월 d일 HH:mm');

  late Future<RecommendationItem> _detailFuture;
  RecommendationItem? _currentItem;
  StockQuote? _quote;
  int? _loadedQuoteStockId;
  bool _isRefreshingLatest = false;
  bool _isLoadingQuote = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.initialItem;
    _detailFuture = _recommendationService.fetchRecommendationDetail(
      widget.portfolioItemId,
    );
    _detailFuture.then(_applyFetchedItem).catchError((_) {});

    if (widget.initialItem != null) {
      _loadQuote(widget.initialItem!.stockId);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshLatestRecommendation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${widget.initialItem?.name ?? '종목'} 상세'),
      ),
      body: FutureBuilder<RecommendationItem>(
        future: _detailFuture,
        initialData: widget.initialItem,
        builder: (context, snapshot) {
          final item = _currentItem ?? snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting &&
              item == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && item == null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AppSectionCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '상세 추천을 불러오지 못했어요.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '잠시 후 다시 시도하면 최신 분석 결과를 다시 가져올 수 있어요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reload,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              ),
            );
          }

          final resolvedItem = item!;
          final currencyController = CurrencyScope.of(context);

          return ListenableBuilder(
            listenable: currencyController,
            builder: (context, _) {
              final currentAmount = CurrencyFormatter.formatAmount(
                usdAmount: resolvedItem.currentAmountUsd,
                currency: currencyController.displayCurrency,
                usdToKrwRate: currencyController.usdToKrwRate,
              );
              final recommendedAmount = CurrencyFormatter.formatAmount(
                usdAmount: resolvedItem.recommendedAmountUsd,
                currency: currencyController.displayCurrency,
                usdToKrwRate: currencyController.usdToKrwRate,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  if (_isRefreshingLatest)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                  _DetailStatusCard(
                    isRefreshingLatest: _isRefreshingLatest,
                    message: _statusMessage,
                  ),
                  const SizedBox(height: 12),
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailLogo(
                              ticker: resolvedItem.ticker,
                              logoUrl: resolvedItem.logoUrl,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resolvedItem.name,
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    resolvedItem.ticker,
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
                            RecommendationBadge(status: resolvedItem.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _LivePriceCard(
                          quote: _quote,
                          isLoading: _isLoadingQuote,
                          displayCurrency: currencyController.displayCurrency,
                          usdToKrwRate: currencyController.usdToKrwRate,
                          quoteTimeFormat: _quoteTimeFormat,
                        ),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            resolvedItem.note,
                            key: ValueKey(resolvedItem.note),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: '현재 매일 모으기',
                          value: currentAmount,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          label: '추천 금액',
                          value: recommendedAmount,
                          accentColor: resolvedItem.status.color,
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
                          value: '${resolvedItem.confidence}%',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniMetricCard(
                          label: '점수',
                          value: '${resolvedItem.score}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniMetricCard(
                          label: '보유 수량',
                          value: resolvedItem.currentHolding,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppSectionCard(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                '추천 근거',
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            if (_buildRecommendationMetaLabel(resolvedItem)
                                case final label?)
                              Text(
                                label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: MaeMojiColors.inkMuted,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '이 종목의 매일 모으기 금액을 어떻게 판단했는지 핵심 이유를 모아 보여드려요.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        EvidenceSection(items: resolvedItem.evidence),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                '관련 뉴스 분석',
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            if (_buildNewsMetaLabel(resolvedItem)
                                case final newsLabel?)
                              Text(
                                newsLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: MaeMojiColors.inkMuted,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          resolvedItem.relatedNews.isEmpty
                              ? (resolvedItem.relatedNewsStatusMessage ??
                                    '오늘 관련 뉴스가 아직 없습니다.')
                              : '감성, 관련성, 영향도를 반영한 기사별 분석입니다.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (resolvedItem.relatedNews.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...resolvedItem.relatedNews.asMap().entries.map((
                            entry,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    entry.key ==
                                        resolvedItem.relatedNews.length - 1
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
                  const SizedBox(height: 14),
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('내 메모', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 10),
                        _MetaLine(
                          label: '투자 시작일',
                          value: resolvedItem.startedAt,
                        ),
                        const SizedBox(height: 8),
                        _MetaLine(
                          label: '메모',
                          value: resolvedItem.memo.isEmpty
                              ? '등록된 메모가 없습니다.'
                              : resolvedItem.memo,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _reload() {
    setState(() {
      _statusMessage = null;
      _detailFuture = _recommendationService.fetchRecommendationDetail(
        widget.portfolioItemId,
      );
    });
    _detailFuture.then(_applyFetchedItem).catchError((_) {});
    _refreshLatestRecommendation();
  }

  Future<void> _refreshLatestRecommendation() async {
    if (_isRefreshingLatest) {
      return;
    }

    setState(() {
      _isRefreshingLatest = true;
      _statusMessage = _buildStoredRecommendationMessage(_currentItem);
    });

    try {
      final refreshedItem = await _recommendationService
          .refreshRecommendationDetail(widget.portfolioItemId);
      if (!mounted) {
        return;
      }

      final mergedItem = _mergeNewsIfNeeded(_currentItem, refreshedItem);
      final hasVisibleChange = _hasMeaningfulDifference(
        _currentItem,
        mergedItem,
      );
      setState(() {
        _currentItem = mergedItem;
        _statusMessage = hasVisibleChange
            ? '방금 최신 분석 결과를 반영했어요.'
            : '방금 최신 뉴스와 가격까지 확인했어요.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = '최신 확인이 조금 지연되고 있어요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingLatest = false;
        });
      }
    }
  }

  void _applyFetchedItem(RecommendationItem item) {
    if (!mounted) {
      return;
    }
    setState(() {
      _currentItem = item;
    });
    _loadQuote(item.stockId);
  }

  Future<void> _loadQuote(int stockId) async {
    if (_isLoadingQuote || _loadedQuoteStockId == stockId) {
      return;
    }

    setState(() {
      _isLoadingQuote = true;
    });

    try {
      final quote = await _stockQuoteService.fetchQuote(stockId);
      if (!mounted) {
        return;
      }

      setState(() {
        _quote = quote;
        _loadedQuoteStockId = stockId;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadedQuoteStockId = stockId;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQuote = false;
        });
      }
    }
  }

  RecommendationItem _mergeNewsIfNeeded(
    RecommendationItem? previous,
    RecommendationItem next,
  ) {
    if (next.relatedNews.isNotEmpty || previous == null) {
      return next;
    }
    if (previous.relatedNews.isEmpty) {
      return next;
    }

    return RecommendationItem(
      portfolioItemId: next.portfolioItemId,
      stockId: next.stockId,
      name: next.name,
      ticker: next.ticker,
      logoUrl: next.logoUrl,
      currentAmountUsd: next.currentAmountUsd,
      recommendedAmountUsd: next.recommendedAmountUsd,
      confidence: next.confidence,
      currentHolding: next.currentHolding,
      startedAt: next.startedAt,
      memo: next.memo,
      score: next.score,
      note: next.note,
      status: next.status,
      evidence: next.evidence,
      relatedNews: previous.relatedNews,
      recommendationDate: next.recommendationDate,
      recommendationGeneratedAt: next.recommendationGeneratedAt,
      newsAnalyzedAt: next.newsAnalyzedAt ?? previous.newsAnalyzedAt,
      relatedNewsStatusMessage:
          next.relatedNewsStatusMessage ??
          '오늘 새 관련 뉴스가 적어 최근 확인된 뉴스를 함께 보여드리고 있어요.',
    );
  }

  String _buildStoredRecommendationMessage(RecommendationItem? item) {
    final generatedAt = item?.recommendationGeneratedAt?.toLocal();
    if (generatedAt == null) {
      return '최근 저장된 추천을 먼저 보여드리고, 최신 정보를 다시 확인하고 있어요.';
    }
    if (_isToday(generatedAt)) {
      return '오늘 저장된 추천을 먼저 보여드리고, 최신 정보를 다시 확인하고 있어요.';
    }
    if (_isYesterday(generatedAt)) {
      return '어제 저장된 추천을 먼저 보여드리고, 최신 정보를 다시 확인하고 있어요.';
    }
    return '최근 저장된 추천을 먼저 보여드리고, 최신 정보를 다시 확인하고 있어요.';
  }

  String? _buildRecommendationMetaLabel(RecommendationItem item) {
    final generatedAt = item.recommendationGeneratedAt?.toLocal();
    if (generatedAt != null) {
      return '추천 계산 ${_metaTimeFormat.format(generatedAt)}';
    }

    final recommendationDate = item.recommendationDate?.toLocal();
    if (recommendationDate != null) {
      return '추천 기준 ${_formatDateOnly(recommendationDate)}';
    }

    return null;
  }

  String? _buildNewsMetaLabel(RecommendationItem item) {
    final analyzedAt = item.newsAnalyzedAt?.toLocal();
    if (analyzedAt == null) {
      return null;
    }
    return '뉴스 확인 ${_formatDateOnly(analyzedAt)}';
  }

  String _formatDateOnly(DateTime value) {
    final local = value.toLocal();
    return '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime value) {
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }

  bool _isYesterday(DateTime value) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return value.year == yesterday.year &&
        value.month == yesterday.month &&
        value.day == yesterday.day;
  }

  bool _hasMeaningfulDifference(
    RecommendationItem? current,
    RecommendationItem next,
  ) {
    if (current == null) {
      return true;
    }

    return current.score != next.score ||
        current.confidence != next.confidence ||
        current.status != next.status ||
        current.note != next.note ||
        current.currentAmountUsd != next.currentAmountUsd ||
        current.recommendedAmountUsd != next.recommendedAmountUsd ||
        current.relatedNews.length != next.relatedNews.length;
  }
}

class _DetailStatusCard extends StatelessWidget {
  const _DetailStatusCard({
    required this.isRefreshingLatest,
    required this.message,
  });

  final bool isRefreshingLatest;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (isRefreshingLatest)
        const _StatusChip(label: '최신 분석 중', color: MaeMojiColors.reduce),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MaeMojiColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chips.isNotEmpty)
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          if (message != null) ...[
            SizedBox(height: chips.isNotEmpty ? 10 : 0),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: MaeMojiColors.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LivePriceCard extends StatelessWidget {
  const _LivePriceCard({
    required this.quote,
    required this.isLoading,
    required this.displayCurrency,
    required this.usdToKrwRate,
    required this.quoteTimeFormat,
  });

  final StockQuote? quote;
  final bool isLoading;
  final DisplayCurrency displayCurrency;
  final double? usdToKrwRate;
  final DateFormat quoteTimeFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedQuote = quote;

    if (resolvedQuote == null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              isLoading ? '현재가를 불러오는 중이에요.' : '현재가 정보를 아직 불러오지 못했어요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: MaeMojiColors.inkMuted,
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      );
    }

    final showKrw =
        displayCurrency == DisplayCurrency.krw &&
        usdToKrwRate != null &&
        usdToKrwRate! > 0;
    final primaryPrice = CurrencyFormatter.formatAmount(
      usdAmount: resolvedQuote.currentPrice,
      currency: showKrw ? DisplayCurrency.krw : DisplayCurrency.usd,
      usdToKrwRate: usdToKrwRate,
    );
    final convertedChange = showKrw && usdToKrwRate != null
        ? resolvedQuote.change * usdToKrwRate!
        : resolvedQuote.change;
    final changePrefix = convertedChange > 0 ? '+' : '';
    final percentPrefix = resolvedQuote.percentChange > 0 ? '+' : '';
    final changeColor = resolvedQuote.change > 0
        ? MaeMojiColors.increase
        : resolvedQuote.change < 0
        ? MaeMojiColors.stop
        : MaeMojiColors.inkMuted;
    final changeText = showKrw
        ? '$changePrefix${convertedChange.toStringAsFixed(0)}원'
        : '$changePrefix${convertedChange.toStringAsFixed(2)} USD';
    final quotedAt = _formatQuoteTime(
      resolvedQuote.quoteTimestamp,
      quoteTimeFormat,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                primaryPrice,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MaeMojiColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$percentPrefix${resolvedQuote.percentChange.toStringAsFixed(2)}% · $changeText',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: changeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                quotedAt == null ? '가격 시각 확인 중' : '가격 기준 $quotedAt',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  color: MaeMojiColors.inkMuted,
                ),
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ],
    );
  }

  static String? _formatQuoteTime(int? timestamp, DateFormat formatter) {
    if (timestamp == null || timestamp <= 0) {
      return null;
    }

    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    ).toLocal();
    return formatter.format(dateTime);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

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
          fontSize: 12,
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
                  child: const Text('뉴스 보기'),
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
      ).showSnackBar(const SnackBar(content: Text('뉴스 링크를 열 수 없어요.')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('뉴스 링크를 여는 데 실패했어요.')));
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
