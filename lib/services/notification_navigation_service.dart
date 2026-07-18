import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'app_navigation_service.dart';
import 'portfolio_insight_service.dart';
import 'web_notification_payload_helper.dart';
import 'web_foreground_notification.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final NotificationNavigationService instance =
      NotificationNavigationService._();

  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  final PortfolioInsightService _portfolioInsightService =
      const PortfolioInsightService();
  bool _initialized = false;
  int? _pendingAlertReadId;

  Future<void> initializeIfSupported() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    final webPayload = consumeWebNotificationPayload();
    if (webPayload != null && webPayload.trim().isNotEmpty) {
      handleLocalNotificationPayload(webPayload);
    }

    if (kIsWeb) {
      _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
        _showWebForegroundNotification,
      );
      return;
    }

    _messageOpenedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessage(initialMessage);
    }
  }

  void handleLocalNotificationPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      _navigateFromData(decoded);
    } catch (_) {
      // 로컬 알림 payload 파싱 실패는 조용히 무시합니다.
    }
  }

  void _handleRemoteMessage(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  void _showWebForegroundNotification(RemoteMessage message) {
    unawaited(
      showWebForegroundNotification(
        title: message.notification?.title ?? '매모지 알림',
        body: message.notification?.body ?? '새로운 알림이 도착했어요.',
      ),
    );
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final portfolioItemId = int.tryParse(
      (data['portfolioItemId'] ?? '').toString(),
    );
    if (portfolioItemId == null || portfolioItemId <= 0) {
      return;
    }

    final alertId = int.tryParse((data['alertId'] ?? '').toString());
    final alertType = (data['alertType'] ?? data['type'] ?? '').toString();
    final focusSection = (data['focusSection'] ?? '').toString();
    if (alertId != null && alertId > 0) {
      if (AppNavigationService.instance.navigatorKey.currentState == null) {
        _pendingAlertReadId = alertId;
      } else {
        unawaited(_markAlertAsRead(alertId));
      }
    }
    AppNavigationService.instance.openPortfolioItemFromAlert(
      portfolioItemId: portfolioItemId,
      alertType: alertType,
      alertId: alertId,
      focusSection: focusSection,
    );
  }

  void flushPendingIfAny() {
    final alertId = _pendingAlertReadId;
    if (alertId == null || alertId <= 0) {
      return;
    }
    _pendingAlertReadId = null;
    unawaited(_markAlertAsRead(alertId));
  }

  Future<void> _markAlertAsRead(int alertId) async {
    try {
      await _portfolioInsightService.markAlertAsRead(alertId);
    } catch (_) {
      // 알림 진입 시 읽음 처리가 늦어져도 상세 이동 자체는 막지 않습니다.
    }
  }
}
