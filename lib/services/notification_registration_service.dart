import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/user_device_info.dart';
import 'portfolio_insight_service.dart';

class NotificationRegistrationService {
  NotificationRegistrationService._();

  static final NotificationRegistrationService instance =
      NotificationRegistrationService._();

  final PortfolioInsightService _portfolioInsightService =
      const PortfolioInsightService();

  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _initialized = false;
  bool _syncInProgress = false;

  Future<void> initializeIfSupported() async {
    if (_initialized || !_isSupportedPlatform) {
      return;
    }

    _initialized = true;
    _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
        .listen((token) {
          unawaited(_registerToken(token));
        });

    await syncNow();
  }

  Future<UserDeviceInfo?> syncNow() async {
    if (!_isSupportedPlatform || _syncInProgress) {
      return null;
    }

    _syncInProgress = true;
    try {
      final permission = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final isAuthorized =
          permission.authorizationStatus == AuthorizationStatus.authorized ||
          permission.authorizationStatus == AuthorizationStatus.provisional;
      if (!isAuthorized) {
        return null;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.trim().isEmpty) {
        return null;
      }

      return await _registerToken(token);
    } catch (_) {
      return null;
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> deactivateCurrentToken() async {
    if (!_isSupportedPlatform) {
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.trim().isEmpty) {
        return;
      }
      await _portfolioInsightService.deactivateNotificationDevice(token);
    } catch (_) {
      // 로그아웃 과정에서는 조용히 실패를 삼킵니다.
    }
  }

  Future<UserDeviceInfo?> _registerToken(String token) async {
    return _portfolioInsightService.upsertNotificationDevice(
      devicePlatform: _devicePlatform,
      fcmToken: token,
      appVersion: null,
      deviceIdentifier: null,
      pushEnabled: true,
    );
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _devicePlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'IOS';
      case TargetPlatform.android:
        return 'ANDROID';
      default:
        return 'WEB';
    }
  }
}
