import 'package:flutter/material.dart';

import '../currency/currency_scope.dart';
import '../models/home_recommendation_summary.dart';
import '../models/recommendation_status.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/currency_toggle.dart';
import '../widgets/navigation_preview_tile.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/status_summary_chip.dart';
import 'screen_blueprint_screen.dart';
import 'stock_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.refreshVersion = 0});

  final int refreshVersion;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecommendationService _recommendationService =
  const RecommendationService();
  late Future<HomeRecommendationSummary> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _recommendationService.fetchHomeRecommendations();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reloadRecommendations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyController = CurrencyScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🍀 오늘의 매모지',
                    maxLines: 1,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '매일 모으기를 지원합니다. \n모든 투자선택은 본인의\n책임입니다.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CurrencyToggle(controller: currencyController),
          ],
        ),
        const SizedBox(height: 20),
        FutureBuilder<HomeRecommendationSummary>(
          future: _recommendationsFuture,
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
                      '추천 결과를 불러오지 못했습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '백엔드 서버 상태를 확인하거나 추천을 다시 생성해 주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reloadRecommendations,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              );
            }

            final summary = snapshot.data!;
            final recommendations = summary.items.take(5).toList();
            if (recommendations.isEmpty) {
              return const AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '아직 생성된 추천이 없습니다.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '포트폴리오 등록 후 추천 화면 또는 홈에서 추천을 불러오면 결과가 나타납니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            final increaseCount = recommendations
                .where((item) => item.status == RecommendationStatus.increase)
                .length;
            final maintainCount = recommendations
                .where((item) => item.status == RecommendationStatus.maintain)
                .length;
            final reduceCount = recommendations
                .where((item) => item.status == RecommendationStatus.reduce)
                .length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatusSummaryChip(
                        label: '증액',
                        count: increaseCount,
                        color: MaeMojiColors.increase,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusSummaryChip(
                        label: '유지',
                        count: maintainCount,
                        color: MaeMojiColors.maintain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusSummaryChip(
                        label: '축소',
                        count: reduceCount,
                        color: MaeMojiColors.reduce,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...recommendations.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecommendationCard(
                      item: item,
                      compact: true,
                      onOpenDetail: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StockDetailScreen(
                              portfolioItemId: item.portfolioItemId,
                              initialItem: item,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        NavigationPreviewTile(
          title: '화면 설계도 보기',
          description: '기획서 기준 전체 화면 목록과 기초 골격 화면들을 한 번에 확인할 수 있습니다.',
          icon: Icons.dashboard_customize_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ScreenBlueprintScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _reloadRecommendations() {
    setState(() {
      _recommendationsFuture = _recommendationService
          .fetchHomeRecommendations();
    });
  }
}
