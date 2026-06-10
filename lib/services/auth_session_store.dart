import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

class AuthSessionStore extends ChangeNotifier {
  AuthSessionStore._();

  static final AuthSessionStore instance = AuthSessionStore._();
  static const String _sessionKey = 'maemoji_auth_session';

  AuthSession? _session;
  bool _initialized = false;

  bool get initialized => _initialized;
  bool get isSignedIn => _session != null && !_session!.isExpired;
  AuthSession? get session => _session;

  String? get accessToken => isSignedIn ? _session!.accessToken : null;

  Map<String, String> get authorizationHeaders {
    final token = accessToken;
    if (token == null || token.isEmpty) {
      return const {};
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_sessionKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final loadedSession = AuthSession.fromJson(decoded);
      if (!loadedSession.isExpired) {
        _session = loadedSession;
      } else {
        await preferences.remove(_sessionKey);
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> save(AuthSession session) async {
    _session = session;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionKey, jsonEncode(session.toJson()));
    notifyListeners();
  }

  Future<void> clear() async {
    _session = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
    notifyListeners();
  }
}
