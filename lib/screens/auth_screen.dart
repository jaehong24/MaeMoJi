import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';
import '../services/auth_session_store.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  bool _submitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFCF4),
              MaeMojiColors.paper,
              Color(0xFFF7F1E5),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -40,
              child: _BackdropCircle(
                size: 260,
                color: Color(0x1AF59E0B),
              ),
            ),
            const Positioned(
              left: -70,
              bottom: 120,
              child: _BackdropCircle(
                size: 190,
                color: Color(0x143B82F6),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: MaeMojiColors.stroke),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x120C111D),
                            blurRadius: 30,
                            offset: Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: MaeMojiColors.paperSoft,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: MaeMojiColors.stroke),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.edit_note_rounded,
                                  size: 28,
                                  color: MaeMojiColors.ink,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '매모지',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _GoogleButton(
                            busy: _submitting,
                            onPressed: _submitting ? null : _signInWithGoogle,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFFD5DA),
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: MaeMojiColors.stop,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: MaeMojiColors.paperAccent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '이런 분께 잘 맞아요',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: MaeMojiColors.ink,
                                  ),
                                ),
                                SizedBox(height: 10),
                                _FeatureRow(text: '매일 조금씩 미국 주식을 모으고 싶은 분'),
                                SizedBox(height: 8),
                                _FeatureRow(text: '뉴스와 추천 이유를 함께 보고 싶은 분'),
                                SizedBox(height: 8),
                                _FeatureRow(text: '내 포트폴리오를 깔끔하게 관리하고 싶은 분'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final session = await _authService.signInWithGoogle();
      await AuthSessionStore.instance.save(session);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _BackdropCircle extends StatelessWidget {
  const _BackdropCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.busy,
    required this.onPressed,
  });

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE4E7EC)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              SvgPicture.asset(
                'assets/logos/google_logo.svg',
                width: 28,
                height: 28,
              ),
            const SizedBox(width: 12),
            Text(
              busy ? 'Google 로그인 연결 중...' : 'Google 계정으로 가입',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: MaeMojiColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: MaeMojiColors.maintain,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: MaeMojiColors.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}
