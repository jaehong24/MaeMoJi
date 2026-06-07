import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../widgets/navigation_preview_tile.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'recommendation_detail_screen.dart';
import 'stock_detail_screen.dart';
import 'stock_search_screen.dart';

/// 기획서 기반 전체 화면 맵을 정리한 허브 화면입니다.
/// 사용자 요청처럼 필요한 화면을 나열하고 실제 진입점도 함께 제공합니다.
class ScreenBlueprintScreen extends StatelessWidget {
  const ScreenBlueprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sampleItem = sampleRecommendations.first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('화면 설계도'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text('기획서 기반 필요 화면', style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            '문서에서 직접 요구한 화면과, 제품 흐름상 꼭 필요한 보조 화면을 함께 묶어 둔 허브입니다.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          NavigationPreviewTile(
            title: '온보딩 화면',
            description: '서비스의 핵심 질문과 가치 제안을 처음 전달하는 진입 화면',
            icon: Icons.waving_hand_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          NavigationPreviewTile(
            title: '회원가입 및 로그인',
            description: 'MVP 포함 항목인 회원가입 흐름의 기본 화면',
            icon: Icons.login_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AuthScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          NavigationPreviewTile(
            title: '종목 검색',
            description: '회사명, 티커, 거래소, 현재가를 보고 종목을 선택한 뒤 바로 등록 단계로 넘어가는 화면',
            icon: Icons.search_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StockSearchScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          NavigationPreviewTile(
            title: '종목 상세',
            description: '차트, 뉴스, 기관활동, 투자자활동, AI 추천을 모아보는 화면',
            icon: Icons.candlestick_chart_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StockDetailScreen(
                    portfolioItemId: sampleItem.portfolioItemId,
                    initialItem: sampleItem,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          NavigationPreviewTile(
            title: '추천 근거',
            description: '왜 증액/유지/축소/중단 판단이 나왔는지 섹션별로 보는 핵심 화면',
            icon: Icons.fact_check_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecommendationDetailScreen(item: sampleItem),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
