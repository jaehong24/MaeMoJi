import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text('설정', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          '알림, 추천 기준 공개, API 연동 상태 같은 환경설정을 두는 화면입니다.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        const AppSectionCard(
          child: Column(
            children: [
              _SettingsRow(title: '기본 테마', value: '라이트'),
              _SettingsRow(title: '추천 엔진 버전', value: 'MVP 더미 데이터'),
              _SettingsRow(title: '시장 데이터 연동', value: '추후 Finnhub 연결 예정'),
              _SettingsRow(title: '뉴스 해석 모델', value: '추후 Gemini 연결 예정', isLast: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.value,
    this.isLast = false,
  });

  final String title;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : MaeMojiColors.stroke,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MaeMojiColors.ink,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: MaeMojiColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
