import 'package:flutter/material.dart';

import '../models/portfolio_item_summary.dart';
import '../services/portfolio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/portfolio_summary_card.dart';
import 'portfolio_entry_screen.dart';
import 'stock_search_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  static const int _maxPortfolioItems = 5;

  final PortfolioService _portfolioService = const PortfolioService();
  late Future<List<PortfolioItemSummary>> _portfolioFuture;

  @override
  void initState() {
    super.initState();
    _portfolioFuture = _portfolioService.fetchPortfolioItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text('포트폴리오', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          '현재 매일 모으는 종목과 적립 금액, 보유 수량, 투자 메모를 실제 저장 데이터 기준으로 관리합니다.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<PortfolioItemSummary>>(
          future: _portfolioFuture,
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <PortfolioItemSummary>[];
            final canAddMore = items.length < _maxPortfolioItems;

            return AppSectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '종목 추가',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MaeMojiColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canAddMore
                              ? '종목 검색 후 바로 포트폴리오에 등록할 수 있습니다. 매일 모으기 금액은 최대 100달러, 등록 종목은 최대 5개까지 가능합니다.'
                              : '모으기 종목은 최대 5개까지만 저장할 수 있습니다. 기존 종목을 수정하거나 삭제한 뒤 다시 추가해 주세요.',
                          style: const TextStyle(
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
                    onPressed: canAddMore ? _openStockSearch : null,
                    child: const Text('종목 검색'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<PortfolioItemSummary>>(
          future: _portfolioFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '포트폴리오를 불러오지 못했습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '백엔드 서버가 켜져 있는지 확인하고 다시 시도해 주세요.',
                      style: TextStyle(color: MaeMojiColors.inkMuted),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reloadPortfolio,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              );
            }

            final items = snapshot.data ?? const [];

            if (items.isEmpty) {
              return const AppSectionCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 42,
                      color: MaeMojiColors.inkMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      '아직 등록된 포트폴리오가 없습니다.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '종목 검색에서 종목을 선택하고 투자 정보를 저장해 보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: items.take(_maxPortfolioItems).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PortfolioSummaryCard(
                    item: item,
                    onEdit: () => _openPortfolioEdit(item),
                    onDelete: () => _confirmDelete(item),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _openStockSearch() async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const StockSearchScreen(),
      ),
    );

    if (didSave == true && mounted) {
      _reloadPortfolio();
    }
  }

  Future<void> _openPortfolioEdit(PortfolioItemSummary item) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PortfolioEntryScreen(
          stockId: item.stockId,
          company: item.companyName,
          ticker: item.ticker,
          exchange: item.exchangeCode,
          price: '',
          initialItem: item,
        ),
      ),
    );

    if (didSave == true && mounted) {
      _reloadPortfolio();
    }
  }

  Future<void> _confirmDelete(PortfolioItemSummary item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('종목 삭제'),
          content: Text('${item.companyName} 종목을 포트폴리오에서 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await _portfolioService.deletePortfolioItem(item.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.companyName} 종목을 삭제했습니다.')),
      );
      _reloadPortfolio();
    } catch (exception) {
      if (!mounted) {
        return;
      }

      final message = exception.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? '포트폴리오 삭제 중 문제가 발생했습니다.' : message,
          ),
        ),
      );
    }
  }

  void _reloadPortfolio() {
    setState(() {
      _portfolioFuture = _portfolioService.fetchPortfolioItems();
    });
  }
}
