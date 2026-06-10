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
          scopes: const ['email', 'profile', 'openid'],
          serverClientId: GoogleAuthConfig.webClientId,
        );

  final GoogleSignIn _googleSignIn;

  Future<AuthSession> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google 로그인이 취소되었습니다.');
    }

    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID 토큰을 가져오지 못했습니다.');
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
      throw Exception('Google 로그인 처리에 실패했습니다. (${response.statusCode})');
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

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
