import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 기존 macOS 창 버튼 느낌 대신,
/// 종이 탭과 메모 제목 조합으로 가볍게 메모 감성을 표현하는 헤더입니다.
class FinderNoteHeader extends StatelessWidget {
  const FinderNoteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: MaeMojiColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120C111D),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: MaeMojiColors.paperAccent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 6,
                  decoration: BoxDecoration(
                    color: MaeMojiColors.paperDeep,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Spacer(),
                const Text(
                  '오늘의 AI 메모',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MaeMojiColors.ink,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: MaeMojiColors.maintain,
                  size: 18,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              children: const [
                Expanded(
                  child: _HeaderMetric(
                    title: '추천 종목',
                    value: '7개',
                    detail: '오늘 재점검 완료',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _HeaderMetric(
                    title: '조정 필요',
                    value: '3개',
                    detail: '증액 1 · 축소 2',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _HeaderMetric(
                    title: '메모 신뢰도',
                    value: '84%',
                    detail: '최근 데이터 반영',
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

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.title,
    required this.value,
    required this.detail,
  });

  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MaeMojiColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: MaeMojiColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 12,
              color: MaeMojiColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
