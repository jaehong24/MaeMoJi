import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final DateTime expiresAt;
  final AuthUser user;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AuthSession copyWith({
    String? accessToken,
    DateTime? expiresAt,
    AuthUser? user,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: (json['accessToken'] ?? '').toString(),
      expiresAt: DateTime.parse((json['expiresAt'] ?? '').toString()),
      user: AuthUser.fromJson(
        (json['user'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }
}
