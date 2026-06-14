import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

class AuthSessionStore extends ChangeNotifier {
  AuthSessionStore._([AuthSessionPersistence? persistence])
    : _persistence = persistence ?? PlatformAuthSessionPersistence();

  static final AuthSessionStore instance = AuthSessionStore._();

  @visibleForTesting
  AuthSessionStore.forTesting(AuthSessionPersistence persistence)
    : _persistence = persistence;

  final AuthSessionPersistence _persistence;
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
    String? raw;
    try {
      raw = await _persistence.read();
    } catch (_) {
      // OS 키 저장소가 복원 과정에서 손상돼도 앱 시작 자체는 계속합니다.
      await _deletePersistedSessionSafely();
    }
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final loadedSession = AuthSession.fromJson(decoded);
        if (!loadedSession.isExpired) {
          _session = loadedSession;
        } else {
          await _deletePersistedSessionSafely();
        }
      } catch (_) {
        _session = null;
        await _deletePersistedSessionSafely();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> save(AuthSession session) async {
    await _persistence.write(jsonEncode(session.toJson()));
    _session = session;
    notifyListeners();
  }

  Future<void> clear() async {
    _session = null;
    await _deletePersistedSessionSafely();
    notifyListeners();
  }

  Future<void> _deletePersistedSessionSafely() async {
    try {
      await _persistence.delete();
    } catch (_) {
      // 로그아웃과 만료 처리는 로컬 저장소 오류보다 우선합니다.
    }
  }
}

abstract interface class AuthSessionPersistence {
  Future<String?> read();

  Future<void> write(String value);

  Future<void> delete();
}

class PlatformAuthSessionPersistence implements AuthSessionPersistence {
  static const String _sessionKey = 'maemoji_auth_session';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(migrateWithBackup: true),
  );

  @override
  Future<String?> read() async {
    if (kIsWeb) {
      return _readLegacy();
    }

    final secureValue = await _secureStorage.read(key: _sessionKey);
    if (secureValue != null && secureValue.isNotEmpty) {
      return secureValue;
    }

    // 기존 앱 버전의 평문 세션을 한 번만 암호화 저장소로 이전합니다.
    final legacyValue = await _readLegacy();
    if (legacyValue != null && legacyValue.isNotEmpty) {
      await _secureStorage.write(key: _sessionKey, value: legacyValue);
      await _deleteLegacy();
    }
    return legacyValue;
  }

  @override
  Future<void> write(String value) async {
    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_sessionKey, value);
      return;
    }

    await _secureStorage.write(key: _sessionKey, value: value);
    await _deleteLegacy();
  }

  @override
  Future<void> delete() async {
    if (!kIsWeb) {
      await _secureStorage.delete(key: _sessionKey);
    }
    await _deleteLegacy();
  }

  Future<String?> _readLegacy() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_sessionKey);
  }

  Future<void> _deleteLegacy() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }
}
