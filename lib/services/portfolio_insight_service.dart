import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/portfolio_reason.dart';
import '../models/portfolio_reason_option.dart';
import '../models/user_device_info.dart';
import '../models/user_alert_event.dart';
import '../models/user_notification_preference.dart';
import '../models/weekly_report.dart';
import '../models/weekly_report_item.dart';
import '../models/weekly_report_list_item.dart';
import 'api_auth_headers.dart';
import 'api_error_message.dart';
import 'api_response_guard.dart';

class PortfolioInsightService {
  const PortfolioInsightService();

  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<List<PortfolioReasonOption>> fetchReasonOptions() async {
    final uri = ApiConfig.buildUri(
      '/api/portfolio-items/reason-options',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('이유 선택 항목을 불러오지 못했습니다. (${response.statusCode})');
    }

    final items = _decodeList(utf8.decode(response.bodyBytes));
    return items
        .map(
          (item) => PortfolioReasonOption(
            code: (item['code'] ?? '').toString(),
            label: (item['label'] ?? '').toString(),
            description: (item['description'] ?? '').toString(),
          ),
        )
        .toList();
  }

  Future<List<PortfolioReason>> fetchPortfolioReasons(int portfolioItemId) async {
    final uri = ApiConfig.buildUri(
      '/api/portfolio-items/$portfolioItemId/reasons',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('저장한 이유를 불러오지 못했습니다. (${response.statusCode})');
    }

    final items = _decodeList(utf8.decode(response.bodyBytes));
    return items
        .map(
          (item) => PortfolioReason(
            code: (item['code'] ?? '').toString(),
            label: (item['label'] ?? '').toString(),
          ),
        )
        .toList();
  }

  Future<List<PortfolioReason>> updatePortfolioReasons(
    int portfolioItemId,
    List<String> reasonCodes,
  ) async {
    final uri = ApiConfig.buildUri(
      '/api/portfolio-items/$portfolioItemId/reasons',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .put(
          uri,
          headers: ApiAuthHeaders.json(),
          body: jsonEncode({'reasonCodes': reasonCodes}),
        )
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('저장', response));
    }

    final items = _decodeList(utf8.decode(response.bodyBytes));
    return items
        .map(
          (item) => PortfolioReason(
            code: (item['code'] ?? '').toString(),
            label: (item['label'] ?? '').toString(),
          ),
        )
        .toList();
  }

  Future<WeeklyReport?> fetchLatestWeeklyReport() async {
    final uri = ApiConfig.buildUri(
      '/api/reports/weekly/latest',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('주간 리포트를 불러오지 못했습니다. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'];
    if (data is! Map<String, dynamic> || data.isEmpty) {
      return null;
    }

    return _toWeeklyReport(data);
  }

  Future<List<WeeklyReportListItem>> fetchWeeklyReports() async {
    final uri = ApiConfig.buildUri(
      '/api/reports/weekly',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('주간 리포트 목록을 불러오지 못했습니다. (${response.statusCode})');
    }

    final items = _decodeList(utf8.decode(response.bodyBytes));
    return items
        .map(
          (item) => WeeklyReportListItem(
            reportId: (item['reportId'] as num?)?.toInt() ?? 0,
            reportWeek: DateTime.tryParse((item['reportWeek'] ?? '').toString()),
            generatedAt: DateTime.tryParse(
              (item['generatedAt'] ?? '').toString(),
            ),
            headline: (item['headline'] ?? '').toString(),
            changedItemCount: (item['changedItemCount'] as num?)?.toInt() ?? 0,
            alertItemCount: (item['alertItemCount'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  Future<List<UserAlertEvent>> fetchAlerts() async {
    final uri = ApiConfig.buildUri(
      '/api/alerts',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('알림을 불러오지 못했습니다. (${response.statusCode})');
    }

    final items = _decodeList(utf8.decode(response.bodyBytes));
    return items.map(_toAlertEvent).toList();
  }

  Future<UserAlertEvent> markAlertAsRead(int alertId) async {
    final uri = ApiConfig.buildUri(
      '/api/alerts/$alertId/read',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .post(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('확인', response));
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return _toAlertEvent(data);
  }

  Future<UserNotificationPreference> fetchNotificationPreferences() async {
    final uri = ApiConfig.buildUri(
      '/api/notifications/preferences',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('알림 설정을 불러오지 못했습니다. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return _toNotificationPreference(data);
  }

  Future<UserNotificationPreference> updateNotificationPreferences(
    UserNotificationPreference preference,
  ) async {
    final uri = ApiConfig.buildUri(
      '/api/notifications/preferences',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .put(
          uri,
          headers: ApiAuthHeaders.json(),
          body: jsonEncode({
            'instantAlertEnabled': preference.instantAlertEnabled,
            'weeklyDigestEnabled': preference.weeklyDigestEnabled,
            'priceRiskAlertEnabled': preference.priceRiskAlertEnabled,
            'newsWeakenedAlertEnabled': preference.newsWeakenedAlertEnabled,
            'statusChangedAlertEnabled': preference.statusChangedAlertEnabled,
            'quietHoursEnabled': preference.quietHoursEnabled,
            'quietHoursStart': preference.quietHoursStart,
            'quietHoursEnd': preference.quietHoursEnd,
            'timezone': preference.timezone,
            'weeklyDigestDay': preference.weeklyDigestDay,
            'weeklyDigestTime': preference.weeklyDigestTime,
          }),
        )
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('저장', response));
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return _toNotificationPreference(data);
  }

  Future<List<UserDeviceInfo>> fetchNotificationDevices() async {
    final uri = ApiConfig.buildUri(
      '/api/notifications/devices',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .get(uri, headers: ApiAuthHeaders.auth())
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('등록된 디바이스를 불러오지 못했습니다. (${response.statusCode})');
    }

    final items = _decodeList(utf8.decode(response.bodyBytes));
    return items.map(_toDeviceInfo).toList();
  }

  Future<UserDeviceInfo> upsertNotificationDevice({
    required String devicePlatform,
    required String fcmToken,
    String? deviceIdentifier,
    String? appVersion,
    bool pushEnabled = true,
  }) async {
    final uri = ApiConfig.buildUri(
      '/api/notifications/devices',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .post(
          uri,
          headers: ApiAuthHeaders.json(),
          body: jsonEncode({
            'devicePlatform': devicePlatform,
            'fcmToken': fcmToken,
            'deviceIdentifier': deviceIdentifier,
            'appVersion': appVersion,
            'pushEnabled': pushEnabled,
          }),
        )
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('등록', response));
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return _toDeviceInfo(data);
  }

  Future<void> deactivateNotificationDevice(String fcmToken) async {
    final uri = ApiConfig.buildUri(
      '/api/notifications/devices',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .delete(
          uri,
          headers: ApiAuthHeaders.json(),
          body: jsonEncode({'fcmToken': fcmToken}),
        )
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('해제', response));
    }
  }

  Future<String> sendTestNotification({
    String? title,
    String? body,
  }) async {
    final uri = ApiConfig.buildUri(
      '/api/notifications/test',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .post(
          uri,
          headers: ApiAuthHeaders.json(),
          body: jsonEncode({
            'title': title,
            'body': body,
          }),
        )
        .timeout(_requestTimeout);
    await clearSessionIfUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception(_buildErrorMessage('테스트 발송', response));
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    final message = (data['message'] ?? '').toString().trim();
    if (message.isNotEmpty) {
      return message;
    }
    return '테스트 알림을 보냈어요.';
  }

  WeeklyReport _toWeeklyReport(Map<String, dynamic> item) {
    final rawItems = (item['items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return WeeklyReport(
      reportId: (item['reportId'] as num?)?.toInt() ?? 0,
      reportWeek: DateTime.tryParse((item['reportWeek'] ?? '').toString()),
      generatedAt: DateTime.tryParse((item['generatedAt'] ?? '').toString()),
      headline: (item['headline'] ?? '').toString(),
      summary: (item['summary'] ?? '').toString(),
      changedItemCount: (item['changedItemCount'] as num?)?.toInt() ?? 0,
      alertItemCount: (item['alertItemCount'] as num?)?.toInt() ?? 0,
      positiveItemCount: (item['positiveItemCount'] as num?)?.toInt() ?? 0,
      negativeItemCount: (item['negativeItemCount'] as num?)?.toInt() ?? 0,
      items: rawItems
          .map(
            (entry) => WeeklyReportItem(
              portfolioItemId: (entry['portfolioItemId'] as num?)?.toInt() ?? 0,
              stockId: (entry['stockId'] as num?)?.toInt() ?? 0,
              companyName: (entry['companyName'] ?? '').toString(),
              ticker: (entry['ticker'] ?? '').toString(),
              logoUrl: _nullableText(entry['logoUrl']),
              currentStatus: (entry['currentStatus'] ?? '').toString(),
              previousStatus: (entry['previousStatus'] ?? '').toString(),
              scoreDelta: (entry['scoreDelta'] as num?)?.toInt() ?? 0,
              headlineLabel: (entry['headlineLabel'] ?? '').toString(),
              changeType: (entry['changeType'] ?? '').toString(),
              summary: (entry['summary'] ?? '').toString(),
            ),
          )
          .toList(),
    );
  }

  UserAlertEvent _toAlertEvent(Map<String, dynamic> item) {
    return UserAlertEvent(
      alertId: (item['alertId'] as num?)?.toInt() ?? 0,
      portfolioItemId: (item['portfolioItemId'] as num?)?.toInt() ?? 0,
      stockId: (item['stockId'] as num?)?.toInt() ?? 0,
      alertType: (item['alertType'] ?? '').toString(),
      title: (item['title'] ?? '').toString(),
      body: (item['body'] ?? '').toString(),
      sentAt: DateTime.tryParse((item['sentAt'] ?? '').toString()),
      readAt: DateTime.tryParse((item['readAt'] ?? '').toString()),
      createdAt: DateTime.tryParse((item['createdAt'] ?? '').toString()),
    );
  }

  UserNotificationPreference _toNotificationPreference(
    Map<String, dynamic> item,
  ) {
    return UserNotificationPreference(
      instantAlertEnabled: item['instantAlertEnabled'] as bool? ?? true,
      weeklyDigestEnabled: item['weeklyDigestEnabled'] as bool? ?? true,
      priceRiskAlertEnabled: item['priceRiskAlertEnabled'] as bool? ?? true,
      newsWeakenedAlertEnabled:
          item['newsWeakenedAlertEnabled'] as bool? ?? true,
      statusChangedAlertEnabled:
          item['statusChangedAlertEnabled'] as bool? ?? true,
      quietHoursEnabled: item['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: _nullableText(item['quietHoursStart']),
      quietHoursEnd: _nullableText(item['quietHoursEnd']),
      timezone: (item['timezone'] ?? 'Asia/Seoul').toString(),
      weeklyDigestDay: (item['weeklyDigestDay'] ?? 'MONDAY').toString(),
      weeklyDigestTime: (item['weeklyDigestTime'] ?? '08:30:00').toString(),
    );
  }

  UserDeviceInfo _toDeviceInfo(Map<String, dynamic> item) {
    return UserDeviceInfo(
      deviceTokenId: (item['deviceTokenId'] as num?)?.toInt() ?? 0,
      devicePlatform: (item['devicePlatform'] ?? '').toString(),
      deviceIdentifier: _nullableText(item['deviceIdentifier']),
      appVersion: _nullableText(item['appVersion']),
      pushEnabled: item['pushEnabled'] as bool? ?? false,
      active: item['active'] as bool? ?? false,
      lastSeenAt: DateTime.tryParse((item['lastSeenAt'] ?? '').toString()),
      createdAt: DateTime.tryParse((item['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((item['updatedAt'] ?? '').toString()),
    );
  }

  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    return (decoded['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
  }

  String? _nullableText(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }

  String _buildErrorMessage(String action, http.Response response) {
    return readApiErrorMessage(
      response,
      fallback: '데이터 $action 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
    );
  }
}
