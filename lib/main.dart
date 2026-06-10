import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSessionStore.instance.load();
  runApp(const MaeMojiApp());
}
