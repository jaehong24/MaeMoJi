import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDevPreferencesStore extends ChangeNotifier {
  LocalDevPreferencesStore._();

  static final LocalDevPreferencesStore instance = LocalDevPreferencesStore._();
  static const String _autoLoginKey = 'maemoji_local_dev_auto_login_enabled';

  bool _initialized = false;
  bool _autoLoginEnabled = true;

  bool get initialized => _initialized;
  bool get autoLoginEnabled => _autoLoginEnabled;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _autoLoginEnabled = preferences.getBool(_autoLoginKey) ?? true;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setAutoLoginEnabled(bool enabled) async {
    _autoLoginEnabled = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_autoLoginKey, enabled);
    notifyListeners();
  }
}
