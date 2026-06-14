class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.profileImageUrl,
    this.riskProfile,
    this.investmentDnaType,
    this.riskProfileScore,
    this.riskProfileConfidence,
    this.riskProfileSource,
  });

  final int userId;
  final String email;
  final String nickname;
  final String profileImageUrl;
  final String? riskProfile;
  final String? investmentDnaType;
  final int? riskProfileScore;
  final int? riskProfileConfidence;
  final String? riskProfileSource;

  bool get hasRiskProfile =>
      riskProfile != null &&
      riskProfile!.isNotEmpty &&
      investmentDnaType != null &&
      investmentDnaType!.isNotEmpty;

  AuthUser copyWith({
    String? riskProfile,
    String? investmentDnaType,
    int? riskProfileScore,
    int? riskProfileConfidence,
    String? riskProfileSource,
  }) {
    return AuthUser(
      userId: userId,
      email: email,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      riskProfile: riskProfile ?? this.riskProfile,
      investmentDnaType: investmentDnaType ?? this.investmentDnaType,
      riskProfileScore: riskProfileScore ?? this.riskProfileScore,
      riskProfileConfidence:
          riskProfileConfidence ?? this.riskProfileConfidence,
      riskProfileSource: riskProfileSource ?? this.riskProfileSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'riskProfile': riskProfile,
      'investmentDnaType': investmentDnaType,
      'riskProfileScore': riskProfileScore,
      'riskProfileConfidence': riskProfileConfidence,
      'riskProfileSource': riskProfileSource,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      email: (json['email'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      profileImageUrl: (json['profileImageUrl'] ?? '').toString(),
      riskProfile: _nullableText(json['riskProfile']),
      investmentDnaType: _nullableText(json['investmentDnaType']),
      riskProfileScore: (json['riskProfileScore'] as num?)?.toInt(),
      riskProfileConfidence: (json['riskProfileConfidence'] as num?)?.toInt(),
      riskProfileSource: _nullableText(json['riskProfileSource']),
    );
  }

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
