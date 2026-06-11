import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MaeMoJi web currently does not use Firebase services directly.
  // Initializing Firebase on web without web options crashes the app at startup.
  // Android native Firebase remains configured separately via google-services.json.
  await AuthSessionStore.instance.load();
  runApp(const MaeMojiApp());
}
