import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_web_config.dart';
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

  Future<UserDeviceInfo?> syncNow({bool reportFailure = false}) async {
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
        if (reportFailure) {
          throw Exception('브라우저 알림 권한이 꺼져 있어요. 주소창의 알림 권한을 허용해 주세요.');
        }
        return null;
      }

      final token = kIsWeb
          ? await _getWebToken()
          : await FirebaseMessaging.instance.getToken();
      if (token == null || token.trim().isEmpty) {
        if (reportFailure) {
          throw Exception('웹 알림 토큰을 만들지 못했어요. 페이지를 새로고침한 뒤 다시 연결해 주세요.');
        }
        return null;
      }

      return await _registerToken(token);
    } catch (exception) {
      if (reportFailure) {
        final message = exception.toString().replaceFirst('Exception: ', '');
        throw Exception(
          message.trim().isEmpty
              ? '웹 알림 연결에 실패했어요. 브라우저 권한과 네트워크를 확인해 주세요.'
              : message,
        );
      }
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
      final token = kIsWeb
          ? await _getWebToken()
          : await FirebaseMessaging.instance.getToken();
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
      return FirebaseWebConfig.hasRequiredOptions &&
          FirebaseWebConfig.hasVapidKey;
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

  Future<String?> _getWebToken() {
    if (!FirebaseWebConfig.hasVapidKey) {
      return Future<String?>.value(null);
    }
    return FirebaseMessaging.instance.getToken(
      vapidKey: FirebaseWebConfig.vapidKey,
    );
  }
}
