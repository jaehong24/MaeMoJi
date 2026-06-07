import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';

/// MVP 포함 항목인 회원가입/로그인 골격 화면입니다.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('회원가입 및 로그인'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text('회원 진입 화면', style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            '사업계획서 MVP 범위에 포함된 회원가입 구조를 위한 기본 화면입니다.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const AppSectionCard(
            child: Column(
              children: [
                _AuthField(label: '이메일', hint: 'name@example.com'),
                SizedBox(height: 12),
                _AuthField(label: '비밀번호', hint: '비밀번호를 입력해주세요'),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: null,
                    child: Text('이메일로 시작 예정'),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text('소셜 로그인 예정'),
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

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.hint,
  });

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: MaeMojiColors.paperSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
          ),
        ),
      ],
    );
  }
}
