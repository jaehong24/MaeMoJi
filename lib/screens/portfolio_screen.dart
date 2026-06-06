import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/portfolio_item_card.dart';
import 'stock_search_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text('포트폴리오', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          '현재 매일 모으는 종목, 적립 금액, 보유 수량, 투자 메모를 한 화면에서 관리합니다.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        AppSectionCard(
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '종목 추가',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '종목 검색 화면에서 회사명, 티커, 거래소, 현재가를 보고 포트폴리오에 추가합니다.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: MaeMojiColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StockSearchScreen(),
                    ),
                  );
                },
                child: const Text('종목 검색'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...sampleRecommendations.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PortfolioItemCard(item: item),
          ),
        ),
      ],
    );
  }
}
