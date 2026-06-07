class ExchangeRate {
  const ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
  });

  final String baseCurrency;
  final String quoteCurrency;
  final double rate;
}
