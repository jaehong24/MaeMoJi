import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';
import '../widgets/evidence_section.dart';
import '../widgets/finder_note_header.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/status_summary_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const FinderNoteHeader(),
        const SizedBox(height: 20),
        Text('오늘의 투자 메모', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          '사용자가 앱을 열자마자 차트가 아니라 오늘 조정이 필요한 추천을 먼저 보도록 구성했습니다.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(
              child: StatusSummaryChip(
                label: '증액',
                count: 1,
                color: MaeMojiColors.increase,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatusSummaryChip(
                label: '유지',
                count: 4,
                color: MaeMojiColors.maintain,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatusSummaryChip(
                label: '축소',
                count: 2,
                color: MaeMojiColors.reduce,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...sampleRecommendations.take(3).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendationCard(item: item),
              ),
            ),
        const SizedBox(height: 12),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('추천 근거 화면 미리보기', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '추천만 보여주지 않고 왜 그런 판단이 나왔는지 종목별 근거를 투명하게 제공하는 구조입니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              EvidenceSection(items: sampleRecommendations.first.evidence),
            ],
          ),
        ),
      ],
    );
  }
}
