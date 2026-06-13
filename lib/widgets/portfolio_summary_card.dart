import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/portfolio_item_summary.dart';
import '../theme/app_theme.dart';
import 'app_section_card.dart';

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final PortfolioItemSummary item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PortfolioLogo(
                ticker: item.ticker,
                logoUrl: item.logoUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.companyName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.ticker} · ${item.exchangeCode}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('매일 모으기 ${item.dailyInvestAmount} USD'),
                    Text(
                      '보유 수량 ${item.holdingQuantity.isEmpty ? '-' : item.holdingQuantity}',
                    ),
                    Text(
                      '투자 시작일 ${item.investmentStartDate.isEmpty ? '-' : item.investmentStartDate}',
                    ),
                    if (item.memo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.memo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MaeMojiColors.inkMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('수정'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('삭제'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MaeMojiColors.stop,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortfolioLogo extends StatelessWidget {
  const _PortfolioLogo({
    required this.ticker,
    this.logoUrl,
  });

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
          width: 52,
          height: 52,
          color: Colors.white,
          child: Image.network(
            resolvedLogoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _PortfolioFallback(shortTicker: shortTicker);
            },
          ),
        ),
      );
    }

    return _PortfolioFallback(shortTicker: shortTicker);
  }
}

class _PortfolioFallback extends StatelessWidget {
  const _PortfolioFallback({required this.shortTicker});

  final String shortTicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
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
