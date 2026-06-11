import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/google_auth_config.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';

class AuthService {
  AuthService()
      : _googleSignIn = GoogleSignIn(
          scopes: const ['email', 'openid'],
          clientId: kIsWeb ? GoogleAuthConfig.webClientId : null,
          serverClientId: kIsWeb ? null : GoogleAuthConfig.webClientId,
        );

  final GoogleSignIn _googleSignIn;

  GoogleSignIn get googleSignIn => _googleSignIn;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<AuthSession> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google 로그인이 취소되었어요.');
    }

    return signInWithGoogleAccount(account);
  }

  Future<void> restoreGoogleSessionIfPossible() async {
    await _googleSignIn.signInSilently();
  }

  Future<AuthSession> signInWithGoogleAccount(GoogleSignInAccount account) async {
    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID 토큰을 가져오지 못했어요.');
    }

    final uri = ApiConfig.buildUri(
      '/api/auth/google',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Google 로그인 처리에 실패했어요. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return AuthSession(
      accessToken: (data['accessToken'] ?? '').toString(),
      expiresAt: DateTime.parse((data['expiresAt'] ?? '').toString()),
      user: AuthUser.fromJson(
        (data['user'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<AuthUser> fetchCurrentUser(String accessToken) async {
    final uri = ApiConfig.buildUri(
      '/api/auth/me',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('세션이 만료되었거나 유효하지 않아요. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return AuthUser.fromJson(data);
  }

  Future<AuthSession> signInAsDev() async {
    final uri = ApiConfig.buildUri(
      '/api/auth/dev',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('로컬 개발 로그인에 실패했어요. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return AuthSession(
      accessToken: (data['accessToken'] ?? '').toString(),
      expiresAt: DateTime.parse((data['expiresAt'] ?? '').toString()),
      user: AuthUser.fromJson(
        (data['user'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Future<void> signOut({String? accessToken}) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      final uri = ApiConfig.buildUri(
        '/api/auth/logout',
        isWeb: kIsWeb,
        platformName: defaultTargetPlatform.name,
      );
      try {
        await http.post(
          uri,
          headers: {'Authorization': 'Bearer $accessToken'},
        );
      } catch (_) {
        // Google sign-out and local session clear should still proceed.
      }
    }

    await _googleSignIn.signOut();
  }
}
