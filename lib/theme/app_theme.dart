import 'package:flutter/material.dart';

/// 앱 전체에서 공유하는 색상 토큰입니다.
/// 따뜻한 종이 질감과 신뢰감 있는 투자 앱 톤을 유지하는 것이 목적입니다.
class MaeMojiColors {
  static const paper = Color(0xFFFFFDF7);
  static const paperSoft = Color(0xFFF8F4EA);
  static const paperDeep = Color(0xFFF0E9DD);
  static const paperAccent = Color(0xFFF5F1E7);

  static const ink = Color(0xFF171717);
  static const inkSoft = Color(0xFF4D5562);
  static const inkMuted = Color(0xFF798190);
  static const stroke = Color(0xFFECE5D8);

  static const increase = Color(0xFF22C55E);
  static const maintain = Color(0xFF3B82F6);
  static const reduce = Color(0xFFF59E0B);
  static const stop = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData light() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: MaeMojiColors.maintain,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: MaeMojiColors.paper,
      colorScheme: baseScheme.copyWith(
        surface: Colors.white,
        primary: MaeMojiColors.maintain,
        secondary: MaeMojiColors.increase,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: MaeMojiColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: MaeMojiColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: MaeMojiColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MaeMojiColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.55,
          color: MaeMojiColors.inkSoft,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: MaeMojiColors.inkSoft,
        ),
      ).apply(
        fontFamily: 'Pretendard',
        bodyColor: MaeMojiColors.inkSoft,
        displayColor: MaeMojiColors.ink,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: MaeMojiColors.stroke),
        ),
      ),
    );
  }
}
