import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum RecommendationStatus {
  increase('증액', MaeMojiColors.increase),
  maintain('유지', MaeMojiColors.maintain),
  reduce('축소', MaeMojiColors.reduce),
  stop('중단', MaeMojiColors.stop);

  const RecommendationStatus(this.label, this.color);

  final String label;
  final Color color;
}
