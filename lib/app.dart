import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'currency/currency_controller.dart';
import 'currency/currency_scope.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'screens/brand_launch_screen.dart';
import 'screens/investment_dna_survey_screen.dart';
import 'screens/nickname_setup_screen.dart';
import 'services/auth_service.dart';
import 'services/auth_session_store.dart';
import 'services/api_exception.dart';
import 'services/local_dev_preferences_store.dart';
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
  final LocalDevPreferencesStore _localDevPreferencesStore =
      LocalDevPreferencesStore.instance;
  bool _checkingSavedSession = true;
  bool _localDevAutoLoginInFlight = false;
  bool _showLaunchScreen = true;

  @override
  void initState() {
    super.initState();
    _currencyController = CurrencyController()..loadExchangeRate();
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showLaunchScreen = false;
      });
    });
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
        home: ListenableBuilder(
          listenable: Listenable.merge([
            _authSessionStore,
            _localDevPreferencesStore,
          ]),
          builder: (context, _) {
            if (_showLaunchScreen) {
              return const BrandLaunchScreen();
            }

            if (!_authSessionStore.initialized ||
                !_localDevPreferencesStore.initialized ||
                _checkingSavedSession) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!_authSessionStore.isSignedIn) {
              if (_shouldAutoLoginLocalDev && !_localDevAutoLoginInFlight) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _signInAsLocalDev();
                });
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const AuthScreen();
            }

            if (!(_authSessionStore.session?.user.nicknameConfirmed ?? false)) {
              return const NicknameSetupScreen();
            }

            if (!(_authSessionStore.session?.user.hasRiskProfile ?? false)) {
              return const InvestmentDnaSurveyScreen();
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
      if (_shouldAutoLoginLocalDev) {
        await _signInAsLocalDev();
        return;
      }
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
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _authSessionStore.clear();
      }
    } catch (_) {
      // 일시적인 네트워크 장애는 정상 세션을 지우지 않습니다.
    } finally {
      if (mounted) {
        setState(() {
          _checkingSavedSession = false;
        });
      }
    }
  }

  bool get _isLocalDevelopment => ApiConfig.isLocalDevelopment(
    isWeb: kIsWeb,
    platformName: defaultTargetPlatform.name,
  );

  bool get _shouldAutoLoginLocalDev =>
      _isLocalDevelopment && _localDevPreferencesStore.autoLoginEnabled;

  Future<void> _signInAsLocalDev() async {
    if (_localDevAutoLoginInFlight) {
      return;
    }

    _localDevAutoLoginInFlight = true;
    if (mounted) {
      setState(() {
        _checkingSavedSession = true;
      });
    }

    try {
      final session = await _authService.signInAsDev();
      await _authSessionStore.save(session);
    } catch (_) {
      await _authSessionStore.clear();
    } finally {
      _localDevAutoLoginInFlight = false;
      if (mounted) {
        setState(() {
          _checkingSavedSession = false;
        });
      }
    }
  }
}
