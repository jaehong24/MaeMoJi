/// 포트폴리오 화면에서 표시할 등록 종목 요약 모델입니다.
class PortfolioItemSummary {
  const PortfolioItemSummary({
    required this.id,
    required this.stockId,
    required this.companyName,
    required this.ticker,
    required this.exchangeCode,
    required this.dailyInvestAmount,
    required this.holdingQuantity,
    required this.investmentStartDate,
    required this.memo,
    this.logoUrl,
  });

  final int id;
  final int stockId;
  final String companyName;
  final String ticker;
  final String exchangeCode;
  final String dailyInvestAmount;
  final String holdingQuantity;
  final String investmentStartDate;
  final String memo;
  final String? logoUrl;
}
