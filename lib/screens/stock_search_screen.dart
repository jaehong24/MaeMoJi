import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';

/// MVP에서는 실제 API 대신 검색 결과 UI 구조를 먼저 고정합니다.
class StockSearchScreen extends StatelessWidget {
  const StockSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('종목 검색'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            '회사명, 티커, 거래소, 현재가를 확인하고 포트폴리오에 추가할 수 있는 화면입니다.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Apple, NVDA, QQQ 등을 검색해보세요',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: MaeMojiColors.stroke),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: MaeMojiColors.stroke),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...const [
            _SearchResultCard(
              company: 'Apple Inc.',
              ticker: 'AAPL',
              exchange: 'NASDAQ',
              price: '\$214.80',
            ),
            SizedBox(height: 12),
            _SearchResultCard(
              company: 'NVIDIA Corp.',
              ticker: 'NVDA',
              exchange: 'NASDAQ',
              price: '\$1,198.40',
            ),
            SizedBox(height: 12),
            _SearchResultCard(
              company: 'Invesco QQQ Trust',
              ticker: 'QQQ',
              exchange: 'NASDAQ',
              price: '\$531.12',
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.company,
    required this.ticker,
    required this.exchange,
    required this.price,
  });

  final String company;
  final String ticker;
  final String exchange;
  final String price;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MaeMojiColors.paperSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: MaeMojiColors.maintain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MaeMojiColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$ticker · $exchange',
                  style: const TextStyle(
                    fontSize: 13,
                    color: MaeMojiColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MaeMojiColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
