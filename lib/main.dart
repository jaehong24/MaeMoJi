import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_session_store.dart';
import 'services/local_dev_preferences_store.dart';
import 'services/notification_display_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MaeMoJi web currently does not use Firebase services directly.
  // Initializing Firebase on web without web options crashes the app at startup.
  // Android native Firebase remains configured separately via google-services.json.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await Firebase.initializeApp();
      await NotificationDisplayService.instance.initializeIfSupported();
    } catch (_) {
      // 모바일 Firebase 초기화 실패는 앱 전체를 막지 않고, 알림 연결만 건너뜁니다.
    }
  }
  await AuthSessionStore.instance.load();
  await LocalDevPreferencesStore.instance.load();
  runApp(const MaeMojiApp());
}
