import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_section_card.dart';

/// 아직 기능이 완성되지 않은 화면도 흐름을 검증할 수 있도록
/// 화면 미리보기 진입용 타일을 공통 위젯으로 분리합니다.
class NavigationPreviewTile extends StatelessWidget {
  const NavigationPreviewTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AppSectionCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: MaeMojiColors.paperSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: MaeMojiColors.maintain),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: MaeMojiColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: MaeMojiColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}
