import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/stock_search_item.dart';
import '../services/maemoji_stock_search_service.dart';
import '../theme/app_theme.dart';
import 'portfolio_entry_screen.dart';

/// 종목 검색어를 입력했을 때만 우리 DB 검색 결과를 보여주는 화면입니다.
class StockSearchScreen extends StatefulWidget {
  const StockSearchScreen({super.key});

  @override
  State<StockSearchScreen> createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  static const int _pageSize = 10;

  final TextEditingController _searchController = TextEditingController();
  final MaeMojiStockSearchService _searchService =
      const MaeMojiStockSearchService();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  List<StockSearchItem> _allResults = const [];
  int _visibleCount = _pageSize;
  int _searchRequestVersion = 0;

  bool get _hasQuery => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleResults = _allResults.take(_visibleCount).toList();
    final hasMore = _visibleCount < _allResults.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('종목 검색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '등록할 종목을 검색하고 선택하면 바로 포트폴리오 입력 단계로 넘어갑니다.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _handleKeywordChanged,
                  decoration: InputDecoration(
                    hintText: '회사명 또는 티커 검색',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearQuery,
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: MaeMojiColors.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: MaeMojiColors.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: MaeMojiColors.maintain,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: MaeMojiColors.stop,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: !_hasQuery
                ? const _SearchPrompt()
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _allResults.isEmpty
                        ? const _EmptySearchResult()
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            itemBuilder: (context, index) {
                              if (index == visibleResults.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Center(
                                    child: Text(
                                      '스크롤하면 더 많은 검색 결과를 불러옵니다.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: MaeMojiColors.inkMuted,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final item = visibleResults[index];
                              return _StockSearchRow(item: item);
                            },
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: MaeMojiColors.stroke,
                            ),
                            itemCount: hasMore
                                ? visibleResults.length + 1
                                : visibleResults.length,
                          ),
          ),
        ],
      ),
    );
  }

  /// 입력 중 매 타이핑마다 API를 치지 않기 위해 짧은 디바운스를 둡니다.
  void _handleKeywordChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    final requestVersion = ++_searchRequestVersion;

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final trimmed = value.trim();

      if (trimmed.isEmpty) {
        if (!mounted || requestVersion != _searchRequestVersion) {
          return;
        }

        setState(() {
          _errorMessage = null;
          _isLoading = false;
          _allResults = const [];
          _visibleCount = _pageSize;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final searched = await _searchService.searchStocks(trimmed);

        if (!mounted || requestVersion != _searchRequestVersion) {
          return;
        }

        setState(() {
          _allResults = searched;
          _visibleCount = _pageSize;
          _isLoading = false;
        });
      } catch (_) {
        if (!mounted || requestVersion != _searchRequestVersion) {
          return;
        }

        setState(() {
          _isLoading = false;
          _allResults = const [];
          _visibleCount = _pageSize;
          _errorMessage = '실시간 검색 중 문제가 생겼습니다. 잠시 후 다시 시도해주세요.';
        });
      }
    });
  }

  void _clearQuery() {
    _searchController.clear();
    _debounce?.cancel();
    _searchRequestVersion++;

    setState(() {
      _isLoading = false;
      _errorMessage = null;
      _allResults = const [];
      _visibleCount = _pageSize;
    });
  }

  /// 하단에 가까워지면 검색 결과를 10개씩 추가로 보여줍니다.
  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoading) {
      return;
    }

    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 180;

    if (!isNearBottom || _visibleCount >= _allResults.length) {
      return;
    }

    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, _allResults.length);
    });
  }
}

class _StockSearchRow extends StatelessWidget {
  const _StockSearchRow({required this.item});

  final StockSearchItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final didSave = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => PortfolioEntryScreen(
              stockId: item.id,
              company: item.koreanName,
              ticker: item.ticker,
              exchange: item.exchange,
              price: item.displayPrice.isEmpty ? '실시간 가격 연동 예정' : item.displayPrice,
            ),
          ),
        );

        if (didSave == true && context.mounted) {
          Navigator.of(context).pop(true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            _TickerAvatar(
              ticker: item.ticker,
              logoUrl: item.logoUrl,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.koreanName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: MaeMojiColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.ticker,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MaeMojiColors.inkMuted,
                          ),
                        ),
                      ),
                      if (item.isEtf) ...[
                        const SizedBox(width: 8),
                        const _AssetTypeBadge(label: 'ETF'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right_rounded,
              color: MaeMojiColors.inkMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTypeBadge extends StatelessWidget {
  const _AssetTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E8C9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE2D1A3),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: MaeMojiColors.ink,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _TickerAvatar extends StatelessWidget {
  const _TickerAvatar({
    required this.ticker,
    required this.logoUrl,
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
              return _TickerFallback(shortTicker: shortTicker);
            },
          ),
        ),
      );
    }

    return _TickerFallback(shortTicker: shortTicker);
  }
}

class _TickerFallback extends StatelessWidget {
  const _TickerFallback({required this.shortTicker});

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

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 44,
              color: MaeMojiColors.inkMuted,
            ),
            SizedBox(height: 12),
            Text(
              '종목명이나 티커를 검색해보세요.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MaeMojiColors.ink,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '검색하면 해당 종목과 회사 이미지를 함께 보여드립니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MaeMojiColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: MaeMojiColors.inkMuted,
            ),
            SizedBox(height: 12),
            Text(
              '검색 결과가 없습니다.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MaeMojiColors.ink,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '회사명이나 티커를 다시 확인해보세요.',
              style: TextStyle(
                fontSize: 14,
                color: MaeMojiColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
