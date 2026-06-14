class RiskProfileResult {
  const RiskProfileResult({
    required this.score,
    required this.riskProfile,
    required this.investmentDnaType,
    required this.title,
    required this.summary,
    required this.preference,
    required this.suggestedAllocation,
  });

  final int score;
  final String riskProfile;
  final String investmentDnaType;
  final String title;
  final String summary;
  final String preference;
  final Map<String, int> suggestedAllocation;

  factory RiskProfileResult.fromJson(Map<String, dynamic> json) {
    final allocation = <String, int>{};
    final rawAllocation = json['suggestedAllocation'];
    if (rawAllocation is Map) {
      for (final entry in rawAllocation.entries) {
        allocation[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
      }
    }

    return RiskProfileResult(
      score: (json['score'] as num?)?.toInt() ?? 0,
      riskProfile: (json['riskProfile'] ?? '').toString(),
      investmentDnaType: (json['investmentDnaType'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      preference: (json['preference'] ?? '').toString(),
      suggestedAllocation: allocation,
    );
  }
}
