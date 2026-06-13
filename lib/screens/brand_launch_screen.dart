import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandLaunchScreen extends StatelessWidget {
  const BrandLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFCF4), MaeMojiColors.paper, Color(0xFFF6EEDC)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: _GlowOrb(size: 220, color: const Color(0x1AF59E0B)),
            ),
            Positioned(
              left: -50,
              bottom: -20,
              child: _GlowOrb(size: 180, color: const Color(0x143B82F6)),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 184,
                        height: 184,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(46),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x150C111D),
                              blurRadius: 36,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/branding/maemoji_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        '매모지',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '매일 모으는 투자 흐름을 더 또렷하게',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          color: MaeMojiColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
