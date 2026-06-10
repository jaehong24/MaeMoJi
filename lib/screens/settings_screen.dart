import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/home_recommendation_summary.dart';
import '../services/auth_service.dart';
import '../services/auth_session_store.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/navigation_preview_tile.dart';
import '../widgets/recommendation_freshness_card.dart';
import 'screen_blueprint_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RecommendationService _recommendationService =
      const RecommendationService();
  final AuthService _authService = AuthService();
  final AuthSessionStore _authSessionStore = AuthSessionStore.instance;
  late Future<HomeRecommendationSummary> _freshnessFuture;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _freshnessFuture = _recommendationService.fetchHomeRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apiBaseUrl = ApiConfig.resolveBaseUrl(
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final user = _authSessionStore.session?.user;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text('설정', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          '앱 환경, 배치 상태, 로그인 정보를 확인하는 화면입니다.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        NavigationPreviewTile(
          title: '전체 화면 설계도',
          description: '기획 기반의 전체 화면 흐름과 기초 화면 구성을 한 번에 확인합니다.',
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
        AppSectionCard(
          child: Column(
            children: [
              _SettingsRow(
                title: '로그인 계정',
                value: user == null ? '-' : '${user.nickname}\n${user.email}',
              ),
              const _SettingsRow(title: '자동 배치 시각', value: '매일 오전 6:47 (KST)'),
              _SettingsRow(title: '현재 API 주소', value: apiBaseUrl),
              const _SettingsRow(title: '기본 테마', value: '라이트'),
              const _SettingsRow(title: '종목 검색 소스', value: 'MaeMoji DB 조회'),
              const _SettingsRow(
                title: '뉴스 분석 모델',
                value: 'Gemini 2.5 Flash Lite',
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _signingOut ? null : _signOut,
            child: Text(_signingOut ? '로그아웃 중...' : '로그아웃'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '배치 상태',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<HomeRecommendationSummary>(
          future: _freshnessFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppSectionCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '배치 상태를 불러오지 못했습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '백엔드 연결 상태나 오늘 추천 계산 여부를 확인해 주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reloadFreshness,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              );
            }

            return RecommendationFreshnessCard(summary: snapshot.data!);
          },
        ),
      ],
    );
  }

  void _reloadFreshness() {
    setState(() {
      _freshnessFuture = _recommendationService.fetchHomeRecommendations();
    });
  }

  Future<void> _signOut() async {
    setState(() {
      _signingOut = true;
    });
    try {
      await _authService.signOut();
      await _authSessionStore.clear();
    } finally {
      if (mounted) {
        setState(() {
          _signingOut = false;
        });
      }
    }
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: MaeMojiColors.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
