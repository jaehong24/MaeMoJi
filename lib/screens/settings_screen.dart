import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/navigation_preview_tile.dart';
import 'screen_blueprint_screen.dart';

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
        NavigationPreviewTile(
          title: '전체 화면 설계도',
          description: '기획서 기반으로 필요한 화면들을 정리한 미리보기 허브 화면입니다.',
          icon: Icons.view_sidebar_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ScreenBlueprintScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const AppSectionCard(
          child: Column(
            children: [
              _SettingsRow(title: '기본 테마', value: '라이트'),
              _SettingsRow(title: '추천 엔진 버전', value: 'MVP 더미 데이터'),
              _SettingsRow(title: '종목 검색 소스', value: 'MaeMoji DB 조회'),
              _SettingsRow(
                title: '뉴스 해석 모델',
                value: 'Gemini 2.5 Flash',
                isLast: true,
              ),
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
            style: const TextStyle(fontSize: 14, color: MaeMojiColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
