import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 추천 상태는 기획서 기준 4단계로 고정합니다.
enum RecommendationStatus {
  increase('증액', MaeMojiColors.increase),
  maintain('유지', MaeMojiColors.maintain),
  reduce('축소', MaeMojiColors.reduce),
  stop('중단', MaeMojiColors.stop);

  const RecommendationStatus(this.label, this.color);

  final String label;
  final Color color;
}
