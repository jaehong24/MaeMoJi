import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'config/firebase_web_config.dart';
import 'services/auth_session_store.dart';
import 'services/app_navigation_service.dart';
import 'services/local_dev_preferences_store.dart';
import 'services/notification_display_service.dart';
import 'services/notification_navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    if (FirebaseWebConfig.hasRequiredOptions) {
      try {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: FirebaseWebConfig.apiKey,
            authDomain: FirebaseWebConfig.authDomain,
            projectId: FirebaseWebConfig.projectId,
            storageBucket: FirebaseWebConfig.storageBucket,
            messagingSenderId: FirebaseWebConfig.messagingSenderId,
            appId: FirebaseWebConfig.appId,
            measurementId: FirebaseWebConfig.measurementId.trim().isEmpty
                ? null
                : FirebaseWebConfig.measurementId,
          ),
        );
        await NotificationNavigationService.instance.initializeIfSupported();
      } catch (_) {
        // 웹 Firebase 초기화 실패는 앱 전체를 막지 않고, 웹 푸시만 건너뜁니다.
      }
    }
  } else if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      await Firebase.initializeApp();
      await NotificationDisplayService.instance.initializeIfSupported();
      await NotificationNavigationService.instance.initializeIfSupported();
    } catch (_) {
      // 모바일 Firebase 초기화 실패는 앱 전체를 막지 않고, 알림 연결만 건너뜁니다.
    }
  }
  await AuthSessionStore.instance.load();
  await LocalDevPreferencesStore.instance.load();
  AppNavigationService.instance.flushPendingIfAny();
  NotificationNavigationService.instance.flushPendingIfAny();
  runApp(const MaeMojiApp());
}
