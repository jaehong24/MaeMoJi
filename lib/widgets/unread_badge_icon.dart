import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class UnreadBadgeIcon extends StatelessWidget {
  const UnreadBadgeIcon({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MaeMojiColors.stroke),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: MaeMojiColors.ink,
              size: 21,
            ),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: MaeMojiColors.stop,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
