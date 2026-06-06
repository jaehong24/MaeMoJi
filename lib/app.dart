import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

class MaeMojiApp extends StatelessWidget {
  const MaeMojiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MaeMoJi',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
