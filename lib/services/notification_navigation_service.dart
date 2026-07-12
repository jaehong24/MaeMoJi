import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'app_navigation_service.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final NotificationNavigationService instance =
      NotificationNavigationService._();

  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  bool _initialized = false;

  Future<void> initializeIfSupported() async {
    if (_initialized || kIsWeb) {
      return;
    }

    _initialized = true;

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

  void _navigateFromData(Map<String, dynamic> data) {
    final portfolioItemId = int.tryParse(
      (data['portfolioItemId'] ?? '').toString(),
    );
    if (portfolioItemId == null || portfolioItemId <= 0) {
      return;
    }

    final alertType = (data['alertType'] ?? data['type'] ?? '').toString();
    AppNavigationService.instance.openPortfolioItemFromAlert(
      portfolioItemId: portfolioItemId,
      alertType: alertType,
    );
  }
}
