import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/exchange_rate.dart';

class ExchangeRateService {
  const ExchangeRateService();

  /// 우선 우리 WAS를 조회하고, 실패하면 공개 환율 API로 한 번 더 시도합니다.
  Future<ExchangeRate> fetchUsdKrwRate() async {
    try {
      return await _fetchFromMaeMojiBackend();
    } catch (_) {
      return _fetchFromFrankfurter();
    }
  }

  Future<ExchangeRate> _fetchFromMaeMojiBackend() async {
    final uri = ApiConfig.buildUri(
      '/api/market/exchange-rates/usd-krw',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'MaeMoji exchange rate fetch failed: ${response.statusCode}',
      );
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = (decoded['data'] as Map<String, dynamic>? ?? const {});
    final rate = (data['rate'] as num?)?.toDouble() ?? 0;

    if (rate <= 0) {
      throw Exception('MaeMoji exchange rate is invalid.');
    }

    return ExchangeRate(
      baseCurrency: (data['baseCurrency'] ?? 'USD').toString(),
      quoteCurrency: (data['quoteCurrency'] ?? 'KRW').toString(),
      rate: rate,
    );
  }

  Future<ExchangeRate> _fetchFromFrankfurter() async {
    final uri = Uri.parse(
      'https://api.frankfurter.dev/v2/rates?base=USD&quotes=KRW',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Frankfurter exchange rate fetch failed: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final double rate;
    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      final item = Map<String, dynamic>.from(decoded.first as Map);
      rate = (item['rate'] as num?)?.toDouble() ?? 0;
    } else if (decoded is Map) {
      final body = Map<String, dynamic>.from(decoded);
      final rates = body['rates'] is Map
          ? Map<String, dynamic>.from(body['rates'] as Map)
          : const <String, dynamic>{};
      rate = (rates['KRW'] as num?)?.toDouble() ?? 0;
    } else {
      rate = 0;
    }

    if (rate <= 0) {
      throw Exception('Frankfurter exchange rate is invalid.');
    }

    return ExchangeRate(baseCurrency: 'USD', quoteCurrency: 'KRW', rate: rate);
  }
}
