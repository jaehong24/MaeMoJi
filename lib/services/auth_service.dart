import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/google_auth_config.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'api_exception.dart';
import 'api_error_message.dart';

class AuthService {
  static const String requiredConsentVersion = '2026-06-14';
  static const Duration _requestTimeout = Duration(seconds: 45);

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

  Future<AuthSession> signInWithGoogle({
    required bool requiredConsentAccepted,
  }) async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google 로그인이 취소되었어요.');
    }

    return signInWithGoogleAccount(
      account,
      requiredConsentAccepted: requiredConsentAccepted,
    );
  }

  Future<AuthSession> signInWithGoogleAccount(
    GoogleSignInAccount account, {
    required bool requiredConsentAccepted,
  }) async {
    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID 토큰을 가져오지 못했어요.');
    }

    return signInWithIdToken(
      idToken,
      requiredConsentAccepted: requiredConsentAccepted,
    );
  }

  Future<AuthSession> signInWithIdToken(
    String idToken, {
    required bool requiredConsentAccepted,
  }) async {
    if (idToken.isEmpty) {
      throw Exception('Google ID 토큰을 가져오지 못했어요.');
    }
    if (!requiredConsentAccepted) {
      throw Exception('필수 안내에 동의한 뒤 로그인해주세요.');
    }

    final uri = ApiConfig.buildUri(
      '/api/auth/google',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'idToken': idToken,
            'requiredConsentAccepted': true,
            'consentVersion': requiredConsentVersion,
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw ApiException(
        readApiErrorMessage(
          response,
          fallback: 'Google 로그인 처리에 실패했어요. 잠시 후 다시 시도해주세요.',
        ),
        statusCode: response.statusCode,
      );
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
    final response = await http
        .get(
          uri,
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw ApiException(
        readApiErrorMessage(
          response,
          fallback: '세션이 만료되었거나 유효하지 않아요.',
        ),
        statusCode: response.statusCode,
      );
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return AuthUser.fromJson(data);
  }

  Future<bool> checkNicknameAvailability({
    required String accessToken,
    required String nickname,
  }) async {
    final uri = ApiConfig.buildUri(
      '/api/users/me/nickname-availability',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
      queryParameters: {'nickname': nickname},
    );
    final response = await http
        .get(
          uri,
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        throw Exception('로그인이 만료되었어요. 다시 로그인해주세요.');
      }
      if (response.statusCode == 400) {
        throw Exception(
          readApiErrorMessage(
            response,
            fallback: '닉네임 형식을 다시 확인해주세요.',
          ),
        );
      }
      throw Exception('닉네임 중복 확인에 실패했어요. (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? const {};
    return data['available'] == true;
  }

  Future<AuthUser> updateNickname({
    required String accessToken,
    required String nickname,
  }) async {
    final uri = ApiConfig.buildUri(
      '/api/users/me/nickname',
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final response = await http
        .put(
          uri,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'nickname': nickname}),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        throw Exception('로그인이 만료되었어요. 다시 로그인해주세요.');
      }
      if (response.statusCode == 409) {
        throw Exception('이미 사용 중인 닉네임이에요.');
      }
      if (response.statusCode == 400) {
        throw Exception(
          readApiErrorMessage(
            response,
            fallback: '닉네임 형식을 다시 확인해주세요.',
          ),
        );
      }
      throw Exception('닉네임 저장에 실패했어요. (${response.statusCode})');
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
    final response = await http.post(uri).timeout(_requestTimeout);

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
        await http
            .post(
              uri,
              headers: {'Authorization': 'Bearer $accessToken'},
            )
            .timeout(_requestTimeout);
      } catch (_) {
        // Google sign-out and local session clear should still proceed.
      }
    }

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // 서버 또는 Google 로그아웃 실패와 무관하게 로컬 세션은 제거되어야 합니다.
    }
  }
}
