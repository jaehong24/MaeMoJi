import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/risk_profile_result.dart';
import 'auth_session_store.dart';

class RiskProfileService {
  Future<RiskProfileResult> submitSurvey(
    List<int> answers, {
    String source = 'ONBOARDING_SURVEY',
  }) async {
    final accessToken = AuthSessionStore.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('로그인 정보가 만료됐어요. 다시 로그인해주세요.');
    }

    final uri = ApiConfig.buildUri(
      '/api/users/me/risk-profile',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'answers': answers, 'source': source}),
    );

    if (response.statusCode != 200) {
      throw Exception('투자성향 결과를 저장하지 못했어요. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return RiskProfileResult.fromJson(data);
  }
}
