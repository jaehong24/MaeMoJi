import 'package:flutter/material.dart';

import 'currency/currency_controller.dart';
import 'currency/currency_scope.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

class MaeMojiApp extends StatefulWidget {
  const MaeMojiApp({super.key});

  @override
  State<MaeMojiApp> createState() => _MaeMojiAppState();
}

class _MaeMojiAppState extends State<MaeMojiApp> {
  late final CurrencyController _currencyController;

  @override
  void initState() {
    super.initState();
    _currencyController = CurrencyController()..loadExchangeRate();
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CurrencyScope(
      controller: _currencyController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MaeMoJi',
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
