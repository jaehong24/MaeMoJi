import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/stock_quote.dart';

class StockQuoteService {
  const StockQuoteService();

  String get _host {
    if (kIsWeb) {
      return 'localhost';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }

    return 'localhost';
  }

  /// 종목 등록 전에 현재가를 미리 보여주기 위한 조회입니다.
  Future<StockQuote> fetchQuote(int stockId) async {
    final uri = Uri.http('$_host:8081', '/api/stocks/$stockId/quote');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('MaeMoji stock quote failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
    final item = (decoded['data'] as Map<String, dynamic>? ?? const {});

    return StockQuote(
      stockId: (item['stockId'] as num?)?.toInt() ?? stockId,
      symbol: (item['symbol'] ?? '').toString(),
      currentPrice: (item['currentPrice'] as num?)?.toDouble() ?? 0,
      change: (item['change'] as num?)?.toDouble() ?? 0,
      percentChange: (item['percentChange'] as num?)?.toDouble() ?? 0,
      previousClose: (item['previousClose'] as num?)?.toDouble() ?? 0,
      quoteTimestamp: (item['quoteTimestamp'] as num?)?.toInt(),
    );
  }
}
