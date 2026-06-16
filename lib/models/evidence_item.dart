class EvidenceItem {
  const EvidenceItem({
    required this.evidenceType,
    required this.title,
    required this.body,
    this.scoreImpact,
    this.displayOrder,
    this.rawDataJson,
  });

  final String evidenceType;
  final String title;
  final String body;
  final int? scoreImpact;
  final int? displayOrder;
  final String? rawDataJson;

  bool get isFactor => evidenceType.startsWith('FACTOR_');

  bool get isAiNote => evidenceType == 'AI_NOTE';
}
