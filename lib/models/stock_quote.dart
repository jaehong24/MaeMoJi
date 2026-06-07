class StockQuote {
  const StockQuote({
    required this.stockId,
    required this.symbol,
    required this.currentPrice,
    required this.change,
    required this.percentChange,
    required this.previousClose,
    this.quoteTimestamp,
  });

  final int stockId;
  final String symbol;
  final double currentPrice;
  final double change;
  final double percentChange;
  final double previousClose;
  final int? quoteTimestamp;
}
