import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_navigation_service.dart';

class NotificationDisplayService {
  NotificationDisplayService._();

  static final NotificationDisplayService instance =
      NotificationDisplayService._();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'maemoji_alerts',
        'MaeMoJi Alerts',
        description: '매모지 주요 알림 채널',
        importance: Importance.max,
      );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  bool _initialized = false;

  Future<void> initializeIfSupported() async {
    if (_initialized || kIsWeb) {
      return;
    }

    _initialized = true;

    const androidInitialization = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialization,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        NotificationNavigationService.instance.handleLocalNotificationPayload(
          response.payload,
        );
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
      (message) {
        unawaited(_showForegroundNotification(message));
      },
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'maemoji_alerts',
      'MaeMoJi Alerts',
      channelDescription: '매모지 주요 알림 채널',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }
}
