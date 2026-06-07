import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';

/// 사업계획서의 서비스 메시지를 사용자에게 처음 전달하는 온보딩 화면입니다.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('온보딩'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text('매모지를 처음 만나는 화면', style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            '서비스의 핵심 질문인 "지금 모으고 있는 종목을 계속 모아도 될까요?"를 가장 먼저 전달하는 진입 화면입니다.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '매일 모으고 있지만,\n계속 모아도 될까요?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: MaeMojiColors.ink,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  '매모지는 적립식 투자자를 위해 증액, 유지, 축소, 중단 중 어떤 방향이 적절한지 근거와 함께 정리해주는 AI 투자 코치입니다.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: MaeMojiColors.inkSoft,
                  ),
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: null,
                    child: Text('시작하기 예정'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
