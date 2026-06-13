import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../currency/currency_scope.dart';
import '../models/recommendation_item.dart';
import '../screens/recommendation_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'app_section_card.dart';
import 'recommendation_badge.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.item,
    this.showMemo = true,
    this.onOpenDetail,
    this.compact = false,
  });

  final RecommendationItem item;
  final bool showMemo;
  final VoidCallback? onOpenDetail;
  final bool compact;

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

        final detailAction =
            onOpenDetail ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecommendationDetailScreen(item: item),
                ),
              );
            };

        final card = AppSectionCard(
          padding: EdgeInsets.all(compact ? 18 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecommendationLogo(
                    ticker: item.ticker,
                    logoUrl: item.logoUrl,
                    compact: compact,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: compact
                              ? theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                )
                              : theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.ticker,
                          style: const TextStyle(
                            fontSize: 12,
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _AmountBlock(
                      label: '현재 매일 모으기',
                      amount: currentAmount,
                      compact: compact,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AmountBlock(
                      label: '추천 금액',
                      amount: recommendedAmount,
                      emphasisColor: item.status.color,
                      compact: compact,
                    ),
                  ),
                ],
              ),
              if (showMemo) ...[
                const SizedBox(height: 12),
                Text(
                  item.note,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: detailAction,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('상세 보기'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        return GestureDetector(
          onTap: detailAction,
          behavior: HitTestBehavior.opaque,
          child: card,
        );
      },
    );
  }
}

class _RecommendationLogo extends StatelessWidget {
  const _RecommendationLogo({
    required this.ticker,
    this.logoUrl,
    required this.compact,
  });

  final String ticker;
  final String? logoUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final shortTicker = ticker.length > 3 ? ticker.substring(0, 3) : ticker;
    final size = compact ? 44.0 : 52.0;
    final resolvedLogoUrl = ApiConfig.resolveLogoUrl(
      logoUrl,
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );

    if (resolvedLogoUrl.isNotEmpty) {
      return ClipOval(
        child: Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Image.network(
            resolvedLogoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _RecommendationFallback(
                shortTicker: shortTicker,
                size: size,
              );
            },
          ),
        ),
      );
    }

    return _RecommendationFallback(shortTicker: shortTicker, size: size);
  }
}

class _RecommendationFallback extends StatelessWidget {
  const _RecommendationFallback({
    required this.shortTicker,
    required this.size,
  });

  final String shortTicker;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF21295C),
      ),
      alignment: Alignment.center,
      child: Text(
        shortTicker,
        style: TextStyle(
          fontSize: size == 44 ? 13 : 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({
    required this.label,
    required this.amount,
    this.emphasisColor,
    required this.compact,
  });

  final String label;
  final String amount;
  final Color? emphasisColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
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
          const SizedBox(height: 8),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 18 : 24,
              fontWeight: FontWeight.w700,
              color: emphasisColor ?? MaeMojiColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
