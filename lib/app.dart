import 'package:flutter/material.dart';

import 'currency/currency_controller.dart';
import 'currency/currency_scope.dart';
import 'services/auth_service.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'services/auth_session_store.dart';
import 'theme/app_theme.dart';

class MaeMojiApp extends StatefulWidget {
  const MaeMojiApp({super.key});

  @override
  State<MaeMojiApp> createState() => _MaeMojiAppState();
}

class _MaeMojiAppState extends State<MaeMojiApp> {
  late final CurrencyController _currencyController;
  final AuthService _authService = AuthService();
  final AuthSessionStore _authSessionStore = AuthSessionStore.instance;
  bool _checkingSavedSession = true;

  @override
  void initState() {
    super.initState();
    _currencyController = CurrencyController()..loadExchangeRate();
    _validateSavedSession();
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
        home: AnimatedBuilder(
          animation: _authSessionStore,
          builder: (context, _) {
            if (!_authSessionStore.initialized || _checkingSavedSession) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!_authSessionStore.isSignedIn) {
              return const AuthScreen();
            }

            return const AppShell();
          },
        ),
      ),
    );
  }

  Future<void> _validateSavedSession() async {
    if (!_authSessionStore.initialized) {
      if (mounted) {
        setState(() {
          _checkingSavedSession = false;
        });
      }
      return;
    }

    final session = _authSessionStore.session;
    if (session == null || session.isExpired) {
      if (mounted) {
        setState(() {
          _checkingSavedSession = false;
        });
      }
      return;
    }

    try {
      final user = await _authService.fetchCurrentUser(session.accessToken);
      await _authSessionStore.save(session.copyWith(user: user));
    } catch (_) {
      await _authSessionStore.clear();
    } finally {
      if (mounted) {
        setState(() {
          _checkingSavedSession = false;
        });
      }
    }
  }
}
