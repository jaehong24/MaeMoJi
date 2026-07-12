import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AlertEventPresentation {
  const AlertEventPresentation({
    required this.label,
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color softColor;
}

AlertEventPresentation alertEventPresentation(String alertType) {
  switch (alertType.toUpperCase()) {
    case 'PRICE_RISK':
      return const AlertEventPresentation(
        label: '가격 흔들림',
        icon: Icons.show_chart_rounded,
        color: MaeMojiColors.reduce,
        softColor: Color(0xFFFFF4DD),
      );
    case 'NEWS_WEAKENED':
      return const AlertEventPresentation(
        label: '뉴스 악화',
        icon: Icons.newspaper_rounded,
        color: MaeMojiColors.stop,
        softColor: Color(0xFFFFECE8),
      );
    case 'STATUS_CHANGED':
      return const AlertEventPresentation(
        label: '의견 변경',
        icon: Icons.autorenew_rounded,
        color: MaeMojiColors.maintain,
        softColor: Color(0xFFEFF5FF),
      );
    case 'PRICE_IMPROVED':
      return const AlertEventPresentation(
        label: '가격 안정',
        icon: Icons.insights_rounded,
        color: MaeMojiColors.increase,
        softColor: Color(0xFFEBF9F0),
      );
    case 'FUNDAMENTAL_IMPROVED':
      return const AlertEventPresentation(
        label: '기업 체력 개선',
        icon: Icons.domain_verification_rounded,
        color: MaeMojiColors.increase,
        softColor: Color(0xFFEBF9F0),
      );
    case 'CAUTIOUS_MAINTAIN':
      return const AlertEventPresentation(
        label: '보수적 유지',
        icon: Icons.shield_outlined,
        color: MaeMojiColors.reduce,
        softColor: Color(0xFFFFF4DD),
      );
    case 'NEW_ENTRY':
      return const AlertEventPresentation(
        label: '새 분석',
        icon: Icons.fiber_new_rounded,
        color: MaeMojiColors.maintain,
        softColor: Color(0xFFEFF5FF),
      );
    case 'STABLE_REVIEW':
    default:
      return const AlertEventPresentation(
        label: '다시 확인',
        icon: Icons.visibility_outlined,
        color: MaeMojiColors.maintain,
        softColor: Color(0xFFEFF5FF),
      );
  }
}
