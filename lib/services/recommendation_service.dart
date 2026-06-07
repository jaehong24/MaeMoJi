import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/evidence_item.dart';
import '../models/recommendation_item.dart';
import '../models/recommendation_news_item.dart';
import '../models/recommendation_status.dart';

class RecommendationService {
  const RecommendationService();

  Future<List<RecommendationItem>> fetchRecommendations() async {
    final uri = ApiConfig.buildUri(
      '/api/recommendations',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('추천 조회에 실패했습니다. (${response.statusCode})');
    }

    return _decodeRecommendations(utf8.decode(response.bodyBytes));
  }

  Future<List<RecommendationItem>> generateRecommendations() async {
    final uri = ApiConfig.buildUri(
      '/api/recommendations/generate',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('추천 생성에 실패했습니다. (${response.statusCode})');
    }

    return _decodeRecommendations(utf8.decode(response.bodyBytes));
  }

  List<RecommendationItem> _decodeRecommendations(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final items = (decoded['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return items.map((item) {
      final evidenceItems = (item['evidence'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(
            (evidence) => EvidenceItem(
              title: (evidence['title'] ?? '').toString(),
              body: (evidence['body'] ?? '').toString(),
            ),
          )
          .toList();

      final relatedNews = (item['relatedNews'] as List<dynamic>? ?? const [])
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
              reason: (news['reason'] ?? '').toString(),
              weightedScore: (news['weightedScore'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();

      return RecommendationItem(
        name: (item['companyName'] ?? '').toString(),
        ticker: (item['ticker'] ?? '').toString(),
        logoUrl: (item['logoUrl'] ?? '').toString(),
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
      );
    }).toList();
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
