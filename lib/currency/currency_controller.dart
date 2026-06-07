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

  DisplayCurrency get displayCurrency => _displayCurrency;
  double? get usdToKrwRate => _usdToKrwRate;
  bool get isLoadingRate => _isLoadingRate;
  bool get hasExchangeRate => _usdToKrwRate != null && _usdToKrwRate! > 0;

  Future<void> loadExchangeRate() async {
    if (_isLoadingRate) {
      return;
    }

    _isLoadingRate = true;
    notifyListeners();

    try {
      final rate = await _exchangeRateService.fetchUsdKrwRate();
      _usdToKrwRate = rate.rate;
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
