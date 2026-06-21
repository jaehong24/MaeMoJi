/// 종목 검색 결과 한 줄을 표현하는 모델입니다.
/// 실제 API 연동 시에도 거의 같은 구조를 유지할 수 있습니다.
class StockSearchItem {
  const StockSearchItem({
    required this.id,
    required this.koreanName,
    required this.englishName,
    required this.ticker,
    required this.exchange,
    required this.assetType,
    required this.displayPrice,
    this.logoUrl,
  });

  final int id;
  final String koreanName;
  final String englishName;
  final String ticker;
  final String exchange;
  final String assetType;
  final String displayPrice;
  final String? logoUrl;

  bool get isEtf => assetType.trim().toUpperCase() == 'ETF';
}
