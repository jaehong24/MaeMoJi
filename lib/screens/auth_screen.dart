import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_shell.dart';
import 'investment_dna_survey_screen.dart';
import 'legal_document_screen.dart';
import 'nickname_setup_screen.dart';
import '../config/api_config.dart';
import '../models/auth_session.dart';
import '../services/auth_service.dart';
import '../services/auth_session_store.dart';
import '../services/local_dev_preferences_store.dart';
import '../theme/app_theme.dart';
import '../widgets/google_web_sign_in_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final LocalDevPreferencesStore _localDevPreferencesStore =
      LocalDevPreferencesStore.instance;
  StreamSubscription<GoogleSignInUserData?>? _googleUserSubscription;

  bool _submitting = false;
  bool _devSigningIn = false;
  bool _agreedToRequiredNotice = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _googleUserSubscription = GoogleSignInPlatform.instance.userDataEvents
          ?.listen(_handleWebGoogleUserDataChanged);
    }
  }

  @override
  void dispose() {
    _googleUserSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocalDevelopment = ApiConfig.isLocalDevelopment(
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFCF4), MaeMojiColors.paper, Color(0xFFF7F1E5)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -40,
              child: _BackdropCircle(size: 260, color: Color(0x1AF59E0B)),
            ),
            const Positioned(
              left: -70,
              bottom: 120,
              child: _BackdropCircle(size: 190, color: Color(0x143B82F6)),
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
                                  border: Border.all(
                                    color: MaeMojiColors.stroke,
                                  ),
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
                          if (kIsWeb)
                            Stack(
                              children: [
                                IgnorePointer(
                                  ignoring: !_agreedToRequiredNotice,
                                  child: GoogleWebSignInButton(
                                    googleSignIn: _authService.googleSignIn,
                                  ),
                                ),
                                if (!_agreedToRequiredNotice)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF1F2F4,
                                        ).withValues(alpha: 0.82),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFD7DAE0),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '동의 후 로그인',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: MaeMojiColors.inkMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          else
                            _GoogleButton(
                              busy: _submitting,
                              onPressed: _submitting || !_agreedToRequiredNotice
                                  ? null
                                  : _signInWithGoogle,
                            ),
                          const SizedBox(height: 12),
                          const Text(
                            '매모지는 투자 판단을 돕는 정보와 추천을 제공하며, 최종 투자 결정과 책임은 본인에게 있습니다.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: MaeMojiColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreedToRequiredNotice,
                                onChanged: _submitting
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _agreedToRequiredNotice =
                                              value ?? false;
                                        });
                                      },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    '개인정보 수집·이용 및 서비스 이용 안내에 동의합니다',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: MaeMojiColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                TextButton(
                                  onPressed: _openPrivacyPolicy,
                                  child: const Text('개인정보처리방침'),
                                ),
                                TextButton(
                                  onPressed: _openServiceNotice,
                                  child: const Text('서비스 이용안내'),
                                ),
                              ],
                            ),
                          ),
                          if (!_agreedToRequiredNotice) ...[
                            const SizedBox(height: 2),
                            const Text(
                              '동의 후 Google 로그인 버튼이 활성화됩니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: MaeMojiColors.inkMuted,
                              ),
                            ),
                          ],
                          if (isLocalDevelopment) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: MaeMojiColors.paperSoft,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: MaeMojiColors.stroke),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    value: _localDevPreferencesStore
                                        .autoLoginEnabled,
                                    onChanged: (value) async {
                                      await _localDevPreferencesStore
                                          .setAutoLoginEnabled(value);
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    title: const Text(
                                      '로컬 개발 계정 자동 로그인',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: MaeMojiColors.ink,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      '로컬에서만 dev@maemoji.local 자동 진입을 켜고 끌 수 있어요.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.45,
                                        color: MaeMojiColors.inkMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: _devSigningIn || _submitting
                                          ? null
                                          : _signInAsLocalDev,
                                      child: _devSigningIn
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              '개발 계정으로 바로 시작',
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
      final session = await _authService.signInWithGoogle(
        requiredConsentAccepted: _agreedToRequiredNotice,
      );
      await _completeSignIn(session);
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

  Future<void> _handleWebGoogleUserDataChanged(
    GoogleSignInUserData? userData,
  ) async {
    if (!kIsWeb ||
        userData == null ||
        _submitting ||
        !_agreedToRequiredNotice) {
      return;
    }

    final idToken = userData.idToken;
    if (idToken == null || idToken.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Google ID 토큰을 아직 받지 못했어요. 다시 시도해주세요.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final session = await _authService.signInWithIdToken(
        idToken,
        requiredConsentAccepted: _agreedToRequiredNotice,
      );
      await _completeSignIn(session);
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

  Future<void> _signInAsLocalDev() async {
    setState(() {
      _devSigningIn = true;
      _errorMessage = null;
    });

    try {
      final session = await _authService.signInAsDev();
      await _completeSignIn(session);
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
          _devSigningIn = false;
        });
      }
    }
  }

  Future<void> _completeSignIn(AuthSession session) async {
    await AuthSessionStore.instance.save(session);
    if (!mounted) {
      return;
    }

    final destination = session.user.nicknameConfirmed
        ? (session.user.hasRiskProfile
              ? const AppShell()
              : const InvestmentDnaSurveyScreen())
        : const NicknameSetupScreen();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          titleText: '개인정보처리방침',
          body: LegalDocumentScreen.privacyPolicy,
        ),
      ),
    );
  }

  void _openServiceNotice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          titleText: '서비스 이용안내',
          body: LegalDocumentScreen.serviceNotice,
        ),
      ),
    );
  }
}

class _BackdropCircle extends StatelessWidget {
  const _BackdropCircle({required this.size, required this.color});

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

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onPressed});

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
          backgroundColor: onPressed == null
              ? const Color(0xFFF1F2F4)
              : Colors.white,
          side: BorderSide(
            color: onPressed == null
                ? const Color(0xFFD7DAE0)
                : const Color(0xFFE4E7EC),
          ),
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
