import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/auth_session_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final AuthSessionStore _authSessionStore = AuthSessionStore.instance;
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authSessionStore.session?.user;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text('설정', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text('계정과 앱 기본 정보만 확인할 수 있어요.', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        AppSectionCard(
          child: Column(
            children: [
              _SettingsRow(
                title: '로그인 계정',
                value: user == null ? '-' : '${user.nickname}\n${user.email}',
              ),
              const _SettingsRow(title: '기본 테마', value: '라이트', isLast: true),
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
