class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.profileImageUrl,
  });

  final int userId;
  final String email;
  final String nickname;
  final String profileImageUrl;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      email: (json['email'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      profileImageUrl: (json['profileImageUrl'] ?? '').toString(),
    );
  }
}
