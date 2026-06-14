import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/portfolio_item_summary.dart';
import 'api_auth_headers.dart';
import 'api_error_message.dart';
import 'api_response_guard.dart';

class PortfolioService {
  const PortfolioService();

  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<List<PortfolioItemSummary>> fetchPortfolioItems() async {
    final uri = ApiConfig.buildUri(
      '/api/portfolio-items',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('포트폴리오 조회에 실패했습니다. (${response.statusCode})');
    }

    return _decodePortfolioItems(utf8.decode(response.bodyBytes));
  }

  Future<List<PortfolioItemSummary>> savePortfolioItem({
    required int stockId,
    required String dailyInvestAmount,
    String? holdingQuantity,
    String? investmentStartDate,
    String? memo,
  }) async {
    final uri = ApiConfig.buildUri(
      '/api/portfolio-items',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .post(
          uri,
          headers: ApiAuthHeaders.json(),
          body: jsonEncode({
            'stockId': stockId,
            'dailyInvestAmount': dailyInvestAmount,
            'holdingQuantity': holdingQuantity?.trim().isEmpty ?? true
                ? null
                : holdingQuantity?.trim(),
            'investmentStartDate': investmentStartDate?.trim().isEmpty ?? true
                ? null
                : investmentStartDate?.trim(),
            'memo': memo?.trim().isEmpty ?? true ? null : memo?.trim(),
          }),
        )
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('저장', response));
    }

    return _decodePortfolioItems(utf8.decode(response.bodyBytes));
  }

  Future<List<PortfolioItemSummary>> deletePortfolioItem(int portfolioItemId) async {
    final uri = ApiConfig.buildUri(
      '/api/portfolio-items/$portfolioItemId',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .delete(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('삭제', response));
    }

    return _decodePortfolioItems(utf8.decode(response.bodyBytes));
  }

  List<PortfolioItemSummary> _decodePortfolioItems(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final items = (decoded['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return items.map((item) {
      return PortfolioItemSummary(
        id: (item['id'] as num?)?.toInt() ?? 0,
        stockId: (item['stockId'] as num?)?.toInt() ?? 0,
        companyName: (item['companyName'] ?? '').toString(),
        ticker: (item['ticker'] ?? '').toString(),
        exchangeCode: (item['exchangeCode'] ?? '').toString(),
        dailyInvestAmount: (item['dailyInvestAmount'] ?? '').toString(),
        holdingQuantity: (item['holdingQuantity'] ?? '').toString(),
        investmentStartDate: (item['investmentStartDate'] ?? '').toString(),
        memo: (item['memo'] ?? '').toString(),
        logoUrl: (item['logoUrl'] ?? '').toString(),
      );
    }).toList();
  }

  String _buildErrorMessage(String action, http.Response response) {
    return readApiErrorMessage(
      response,
      fallback: '포트폴리오 $action 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
    );
  }
}
