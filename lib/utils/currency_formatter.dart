import 'package:intl/intl.dart';

import '../models/display_currency.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _krwFormat = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '\u20A9',
    decimalDigits: 0,
  );

  static String formatAmount({
    required double usdAmount,
    required DisplayCurrency currency,
    double? usdToKrwRate,
  }) {
    if (currency == DisplayCurrency.krw && usdToKrwRate != null && usdToKrwRate > 0) {
      return _krwFormat.format(usdAmount * usdToKrwRate);
    }

    return _usdFormat.format(usdAmount);
  }

  static String formatDualPrice({
    required double usdAmount,
    double? usdToKrwRate,
  }) {
    final usdText = _usdFormat.format(usdAmount);

    if (usdToKrwRate == null || usdToKrwRate <= 0) {
      return usdText;
    }

    final krwText = _krwFormat.format(usdAmount * usdToKrwRate);
    return '$usdText / 약 $krwText';
  }
}
