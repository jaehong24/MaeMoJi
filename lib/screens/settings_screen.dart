import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/auth_session_store.dart';
import '../services/local_dev_preferences_store.dart';
import '../theme/app_theme.dart';
import '../utils/risk_profile_labels.dart';
import '../widgets/app_section_card.dart';
import 'investment_dna_survey_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final AuthSessionStore _authSessionStore = AuthSessionStore.instance;
  final LocalDevPreferencesStore _localDevPreferencesStore =
      LocalDevPreferencesStore.instance;
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authSessionStore.session?.user;
    final isLocalDevelopment = ApiConfig.isLocalDevelopment(
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text('설정', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text('계정과 투자성향을 한곳에서 확인할 수 있어요.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        AppSectionCard(
          child: _AccountSummaryCard(user: user),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: user?.hasRiskProfile == true
              ? _RiskProfileSummaryCard(user: user!, onResurvey: _openResurvey)
              : _EmptyRiskProfileCard(onStart: _openSurvey),
        ),
        if (isLocalDevelopment) ...[
          const SizedBox(height: 16),
          AppSectionCard(
            child: ListenableBuilder(
              listenable: _localDevPreferencesStore,
              builder: (context, _) {
                return SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _localDevPreferencesStore.autoLoginEnabled,
                  onChanged: (value) async {
                    await _localDevPreferencesStore.setAutoLoginEnabled(value);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  title: const Text(
                    '로컬 개발 계정 자동 로그인',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                  subtitle: const Text(
                    '켜면 dev@maemoji.local 로 바로 들어가고, 끄면 로그인 화면에서 직접 테스트할 수 있어요.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: MaeMojiColors.inkMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _signingOut ? null : _signOut,
            child: Text(_signingOut ? '로그아웃 중...' : '로그아웃'),
          ),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    setState(() {
      _signingOut = true;
    });
    try {
      await _authService.signOut(accessToken: _authSessionStore.accessToken);
      await _authSessionStore.clear();
    } finally {
      if (mounted) {
        setState(() {
          _signingOut = false;
        });
      }
    }
  }

  Future<void> _openSurvey() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InvestmentDnaSurveyScreen()),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openResurvey() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const InvestmentDnaSurveyScreen(
          source: 'MANUAL_UPDATE',
          contextLabel: '재설문',
        ),
      ),
    );
    if (mounted) {
      setState(() {});
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

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final nickname = (user?.nickname ?? '').trim();
    final email = (user?.email ?? '').trim();
    final resolvedNickname = nickname.isEmpty ? '닉네임 미설정' : nickname;
    final resolvedEmail = email.isEmpty ? '-' : email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '로그인 계정',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          resolvedNickname,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          resolvedEmail,
          style: const TextStyle(
            fontSize: 13,
            color: MaeMojiColors.inkMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        const _SettingsRow(title: '기본 테마', value: '라이트', isLast: true),
      ],
    );
  }
}

class _RiskProfileSummaryCard extends StatelessWidget {
  const _RiskProfileSummaryCard({required this.user, required this.onResurvey});

  final AuthUser user;
  final VoidCallback onResurvey;

  @override
  Widget build(BuildContext context) {
    final allocation = _allocationLabel(user.investmentDnaType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '내 투자성향',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          investmentDnaTypeLabel(user.investmentDnaType),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '총점 ${user.riskProfileScore ?? 0}점 · 신뢰도 ${user.riskProfileConfidence ?? 100}%',
          style: const TextStyle(
            fontSize: 13,
            color: MaeMojiColors.inkMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _summaryText(user),
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: MaeMojiColors.inkSoft,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '추천 자산 배분',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        if (allocation.isEmpty)
          const Text(
            '배분 정보가 아직 없어요.',
            style: TextStyle(fontSize: 13, color: MaeMojiColors.inkMuted),
          )
        else
          ...allocation.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MaeMojiColors.inkSoft,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: MaeMojiColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          user.riskProfileSource == 'ONBOARDING_SURVEY'
              ? '설문으로 저장된 결과예요.'
              : '저장된 투자성향 결과예요.',
          style: const TextStyle(fontSize: 12, color: MaeMojiColors.inkMuted),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onResurvey,
            child: const Text('투자성향 다시 설문하기'),
          ),
        ),
      ],
    );
  }

  String _summaryText(AuthUser user) {
    switch (user.investmentDnaType) {
      case 'SAFE_FIRST':
        return '원금 보존을 가장 중요하게 생각하고, 변동성에 민감한 편이에요.';
      case 'BALANCE_SEEKER':
        return '안정성과 수익 가능성 사이의 균형을 중요하게 생각해요.';
      case 'GROWTH_SEEKER':
        return '미래 수익을 위해 현재 소비를 줄일 수 있고 장기 복리를 중시해요.';
      case 'AGGRESSIVE_INVESTOR':
        return '높은 변동성을 감수하면서 더 큰 장기 수익을 추구하는 편이에요.';
      case 'WEALTH_MASTER':
        return '소비보다 자산 형성과 경제적 자유에 큰 가치를 두는 편이에요.';
      default:
        final riskLabel = riskProfileLabel(user.riskProfile);
        if (riskLabel != '-') {
          return '$riskLabel 기준의 투자성향이 저장되어 있어요.';
        }
        return '투자성향 정보가 아직 없어요.';
    }
  }

  Map<String, int> _allocationLabel(String? type) {
    switch (type) {
      case 'SAFE_FIRST':
        return const {'현금': 40, '채권': 30, 'ETF': 30};
      case 'BALANCE_SEEKER':
        return const {'ETF': 60, '우량주': 20, '채권·현금': 20};
      case 'GROWTH_SEEKER':
        return const {'미국 ETF': 50, '성장주': 30, '현금': 20};
      case 'AGGRESSIVE_INVESTOR':
        return const {'성장주': 50, 'ETF': 40, '현금': 10};
      case 'WEALTH_MASTER':
        return const {'ETF': 40, '성장주': 40, '테마·고위험': 10, '현금': 10};
      default:
        return const {};
    }
  }
}

class _EmptyRiskProfileCard extends StatelessWidget {
  const _EmptyRiskProfileCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '내 투자성향',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '아직 설문이 없어요. 처음 가입할 때 투자 DNA를 한번 정해두면 설정에서 다시 확인할 수 있어요.',
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: MaeMojiColors.inkSoft,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onStart,
            child: const Text('투자성향 설문하기'),
          ),
        ),
      ],
    );
  }
}
