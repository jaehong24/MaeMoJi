import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 반복적으로 쓰는 기본 카드 껍데기입니다.
/// 화면 전반의 둥근 모서리와 부드러운 그림자 톤을 통일합니다.
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: MaeMojiColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0C111D),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}
