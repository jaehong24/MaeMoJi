import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/evidence_item.dart';
import '../models/home_recommendation_summary.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_news_item.dart';
import '../models/recommendation_status.dart';
import 'api_auth_headers.dart';
import 'api_response_guard.dart';

class RecommendationService {
  const RecommendationService();

  static const Duration _readTimeout = Duration(seconds: 30);
  static const Duration _analysisTimeout = Duration(seconds: 90);

  Future<HomeRecommendationSummary> fetchHomeRecommendations() async {
    final uri = ApiConfig.buildUri(
      '/api/recommendations/home',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_readTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('홈 추천 조회에 실패했습니다. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return HomeRecommendationSummary(
      calculatedAt: DateTime.tryParse((data['calculatedAt'] ?? '').toString()),
      recommendationGeneratedAt: DateTime.tryParse(
        (data['recommendationGeneratedAt'] ?? '').toString(),
      ),
      priceDataDate: DateTime.tryParse(
        (data['priceDataDate'] ?? '').toString(),
      ),
      newsAnalyzedAt: DateTime.tryParse(
        (data['newsAnalyzedAt'] ?? '').toString(),
      ),
      items: _decodeRecommendationItems(
        (data['items'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>(),
      ),
    );
  }

  Future<List<RecommendationItem>> fetchRecommendations() async {
    final uri = ApiConfig.buildUri(
      '/api/recommendations',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_readTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('추천 조회에 실패했습니다. (${response.statusCode})');
    }

    return _decodeRecommendations(utf8.decode(response.bodyBytes));
  }

  Future<RecommendationItem> fetchRecommendationDetail(
    int portfolioItemId,
  ) async {
    final uri = ApiConfig.buildUri(
      '/api/recommendations/$portfolioItemId',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_readTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('추천 상세 조회에 실패했습니다. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    final decodedItems = _decodeRecommendationItems([data]);
    if (decodedItems.isEmpty) {
      throw Exception('추천 상세 데이터가 비어 있습니다.');
    }
    return decodedItems.first;
  }

  Future<RecommendationItem> refreshRecommendationDetail(
    int portfolioItemId,
  ) async {
    final uri = ApiConfig.buildUri(
      '/api/recommendations/$portfolioItemId/refresh',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .post(uri, headers: ApiAuthHeaders.auth())
        .timeout(_analysisTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('최신 추천 갱신에 실패했습니다. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    final decodedItems = _decodeRecommendationItems([data]);
    if (decodedItems.isEmpty) {
      throw Exception('최신 추천 데이터가 비어 있습니다.');
    }
    return decodedItems.first;
  }

  Future<List<RecommendationItem>> generateRecommendations() async {
    final uri = ApiConfig.buildUri(
      '/api/recommendations/generate',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .post(uri, headers: ApiAuthHeaders.auth())
        .timeout(_analysisTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('추천 생성에 실패했습니다. (${response.statusCode})');
    }

    return _decodeRecommendations(utf8.decode(response.bodyBytes));
  }

  List<RecommendationItem> _decodeRecommendations(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final items = (decoded['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return _decodeRecommendationItems(items);
  }

  List<RecommendationItem> _decodeRecommendationItems(
    List<Map<String, dynamic>> items,
  ) {
    return items.map((item) {
      final rawEvidenceItems = (item['evidence'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(
            (evidence) => EvidenceItem(
              evidenceType: (evidence['evidenceType'] ?? '').toString(),
              title: (evidence['title'] ?? '').toString(),
              body: (evidence['body'] ?? '').toString(),
              scoreImpact: (evidence['scoreImpact'] as num?)?.toInt(),
              displayOrder: (evidence['displayOrder'] as num?)?.toInt(),
              rawDataJson: _nullableText(evidence['rawDataJson']),
            ),
          )
          .toList();
      final evidenceItems = _deduplicateEvidence(rawEvidenceItems);

      final rawRelatedNews = (item['relatedNews'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .where(
            (news) =>
                (news['relevanceScore'] as num?)?.toInt() != null &&
                (news['relevanceScore'] as num).toInt() >= 60,
          )
          .take(3)
          .map(
            (news) => RecommendationNewsItem(
              headline: (news['headline'] ?? '').toString(),
              summary: (news['summary'] ?? '').toString(),
              sourceName: (news['sourceName'] ?? '').toString(),
              newsUrl: (news['newsUrl'] ?? '').toString(),
              sentimentLabel: (news['sentimentLabel'] ?? 'NEUTRAL').toString(),
              sentimentScore: (news['sentimentScore'] as num?)?.toInt() ?? 0,
              relevanceScore: (news['relevanceScore'] as num?)?.toInt() ?? 0,
              impactLevel: (news['impactLevel'] ?? 'LOW').toString(),
              hardNegativeCategory:
                  (news['hardNegativeCategory'] ?? 'NONE').toString(),
              hardNegativeCategoryLabel:
                  (news['hardNegativeCategoryLabel'] ?? '').toString(),
              reason: (news['reason'] ?? '').toString(),
              weightedScore: (news['weightedScore'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();
      final relatedNews = _deduplicateNews(rawRelatedNews);

      final calculation =
          (item['calculation'] as Map<String, dynamic>?) ?? const {};

      return RecommendationItem(
        portfolioItemId: (item['portfolioItemId'] as num?)?.toInt() ?? 0,
        stockId: (item['stockId'] as num?)?.toInt() ?? 0,
        name: (item['companyName'] ?? '').toString(),
        ticker: (item['ticker'] ?? '').toString(),
        logoUrl: (item['logoUrl'] ?? '').toString(),
        assetType: (item['assetType'] ?? '').toString(),
        analysisStageMessage: _nullableText(item['analysisStageMessage']),
        currentAmountUsd: (item['currentDailyAmount'] as num?)?.toDouble() ?? 0,
        recommendedAmountUsd:
            (item['recommendedDailyAmount'] as num?)?.toDouble() ?? 0,
        confidence: (item['confidence'] as num?)?.toInt() ?? 0,
        currentHolding: (item['currentHolding'] ?? '-').toString(),
        startedAt: (item['investmentStartDate'] ?? '').toString(),
        memo: (item['memo'] ?? '').toString(),
        score: (item['finalScore'] as num?)?.toInt() ?? 0,
        note: (item['aiFinalComment'] ?? '').toString(),
        status: _parseStatus((item['recommendationType'] ?? '').toString()),
        evidence: evidenceItems,
        relatedNews: relatedNews,
        recommendationDate: DateTime.tryParse(
          (item['recommendationDate'] ?? '').toString(),
        ),
        recommendationGeneratedAt: DateTime.tryParse(
          (item['recommendationGeneratedAt'] ?? '').toString(),
        ),
        newsAnalyzedAt: DateTime.tryParse(
          (item['newsAnalyzedAt'] ?? '').toString(),
        ),
        relatedNewsStatusMessage: _nullableText(
          item['relatedNewsStatusMessage'],
        ),
        formulaVersion: (calculation['formulaVersion'] ?? '').toString(),
        priceMomentumScore:
            (calculation['priceMomentumScore'] as num?)?.toInt(),
        priceStabilityScore:
            (calculation['priceStabilityScore'] as num?)?.toInt(),
        fundamentalQualityScore:
            (calculation['fundamentalQualityScore'] as num?)?.toInt(),
        newsScore: (calculation['newsScore'] as num?)?.toInt(),
        userFitScore: (calculation['userFitScore'] as num?)?.toInt(),
        crossFactorAdjustment:
            (calculation['crossFactorAdjustment'] as num?)?.toInt(),
        userAdjustment: (calculation['userAdjustment'] as num?)?.toInt(),
        riskProfileApplied: _nullableText(calculation['riskProfileApplied']),
        confidenceBreakdownJson: _nullableText(
          calculation['confidenceBreakdownJson'],
        ),
      );
    }).toList();
  }

  List<EvidenceItem> _deduplicateEvidence(List<EvidenceItem> items) {
    final deduplicated = <String, EvidenceItem>{};
    for (final item in items) {
      final key = '${item.evidenceType}|${item.title}|${item.body}';
      deduplicated.putIfAbsent(key, () => item);
    }
    return deduplicated.values.toList();
  }

  List<RecommendationNewsItem> _deduplicateNews(
    List<RecommendationNewsItem> items,
  ) {
    final deduplicated = <String, RecommendationNewsItem>{};
    for (final item in items) {
      final normalizedHeadline = item.headline.trim().toLowerCase();
      final normalizedUrl = item.newsUrl.trim().toLowerCase();
      final key = normalizedUrl.isNotEmpty ? normalizedUrl : normalizedHeadline;
      deduplicated.putIfAbsent(key, () => item);
    }
    return deduplicated.values.toList();
  }

  String? _nullableText(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }

  RecommendationStatus _parseStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'INCREASE':
        return RecommendationStatus.increase;
      case 'MAINTAIN':
        return RecommendationStatus.maintain;
      case 'REDUCE':
        return RecommendationStatus.reduce;
      case 'STOP':
        return RecommendationStatus.stop;
      default:
        return RecommendationStatus.maintain;
    }
  }
}
