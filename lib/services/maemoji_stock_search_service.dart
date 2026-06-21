import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/stock_search_item.dart';
import 'api_auth_headers.dart';
import 'api_response_guard.dart';

/// MaeMoJi WAS의 종목 검색 API를 호출하는 서비스입니다.
///
/// 앱은 외부 시세 API를 직접 호출하지 않고, 우리 서버를 통해
/// 종목 검색 결과를 받도록 맞춥니다.
class MaeMojiStockSearchService {
  const MaeMojiStockSearchService();

  static const Duration _requestTimeout = Duration(seconds: 20);

  /// Flutter 검색 화면에서 사용할 종목 목록을 WAS 응답에서 변환합니다.
  Future<List<StockSearchItem>> searchStocks(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return const [];
    }

    final uri = ApiConfig.buildUri(
      '/api/stocks/search',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
      queryParameters: {'keyword': trimmed},
    );

    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('MaeMoji stock search failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
    final items = (decoded['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return items.map(_toStockSearchItem).toList();
  }

  /// 서버 응답 필드를 화면 모델 필드에 맞춰 변환합니다.
  StockSearchItem _toStockSearchItem(Map<String, dynamic> item) {
    final koreanName = (item['nameKo'] ?? '').toString().trim();
    final englishName = (item['nameEn'] ?? '').toString().trim();

    return StockSearchItem(
      id: (item['id'] as num?)?.toInt() ?? 0,
      koreanName: koreanName.isNotEmpty ? koreanName : englishName,
      englishName: englishName,
      ticker: (item['ticker'] ?? '').toString(),
      exchange: (item['exchangeCode'] ?? '').toString(),
      assetType: (item['assetType'] ?? '').toString(),
      displayPrice: '',
      logoUrl: (item['logoUrl'] ?? '').toString(),
    );
  }
}
