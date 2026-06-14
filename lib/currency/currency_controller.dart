import 'package:flutter/material.dart';

import '../models/display_currency.dart';
import '../services/exchange_rate_service.dart';

class CurrencyController extends ChangeNotifier {
  CurrencyController({
    ExchangeRateService? exchangeRateService,
  }) : _exchangeRateService = exchangeRateService ?? const ExchangeRateService();

  final ExchangeRateService _exchangeRateService;

  DisplayCurrency _displayCurrency = DisplayCurrency.usd;
  double? _usdToKrwRate;
  bool _isLoadingRate = false;
  bool _exchangeRateLoadFailed = false;

  DisplayCurrency get displayCurrency => _displayCurrency;
  double? get usdToKrwRate => _usdToKrwRate;
  bool get isLoadingRate => _isLoadingRate;
  bool get exchangeRateLoadFailed => _exchangeRateLoadFailed;
  bool get hasExchangeRate => _usdToKrwRate != null && _usdToKrwRate! > 0;

  Future<void> loadExchangeRate() async {
    if (_isLoadingRate) {
      return;
    }

    _isLoadingRate = true;
    _exchangeRateLoadFailed = false;
    notifyListeners();

    try {
      final rate = await _exchangeRateService.fetchUsdKrwRate();
      _usdToKrwRate = rate.rate;
    } catch (_) {
      // 환율이 없을 때 임의 값을 사용하지 않고 USD 표시를 유지합니다.
      _exchangeRateLoadFailed = true;
    } finally {
      _isLoadingRate = false;
      notifyListeners();
    }
  }

  void setDisplayCurrency(DisplayCurrency currency) {
    if (_displayCurrency == currency) {
      return;
    }

    _displayCurrency = currency;
    notifyListeners();

    if (currency == DisplayCurrency.krw && !hasExchangeRate) {
      loadExchangeRate();
    }
  }
}
