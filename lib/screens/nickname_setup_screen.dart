import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/auth_session_store.dart';
import '../theme/app_theme.dart';
import '../utils/nickname_validator.dart';
import 'app_shell.dart';
import 'auth_screen.dart';
import 'investment_dna_survey_screen.dart';

class NicknameSetupScreen extends StatefulWidget {
  const NicknameSetupScreen({super.key});

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nicknameController = TextEditingController();

  bool _checking = false;
  bool _saving = false;
  bool _nicknameAvailable = false;
  String? _helperMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final currentNickname = AuthSessionStore.instance.session?.user.nickname ?? '';
    _nicknameController.text = NicknameValidator.isValid(currentNickname)
        ? currentNickname
        : '';
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    _nicknameController
      ..removeListener(_onNicknameChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: MaeMojiColors.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: MaeMojiColors.stroke),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120C111D),
                      blurRadius: 26,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '닉네임을 정해주세요',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: MaeMojiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '매모지에서 사용할 이름이에요. 한 번 정한 뒤에도 설정에서 다시 바꿀 수 있도록 이어서 확장할 수 있어요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                        color: MaeMojiColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nicknameController,
                      enabled: !_checking && !_saving,
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        hintText: '',
                        helperText: _helperMessage,
                        errorText: _errorMessage,
                        helperMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _checking || _saving
                                ? null
                                : _checkNicknameAvailability,
                            child: _checking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('중복 확인'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _nicknameAvailable && !_saving
                                ? _saveNickname
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: MaeMojiColors.ink,
                              foregroundColor: Colors.white,
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('다음으로'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '2~12자의 한글, 영문, 숫자, 밑줄(_)로 입력할 수 있어요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: MaeMojiColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNicknameChanged() {
    if (_nicknameAvailable || _helperMessage != null || _errorMessage != null) {
      setState(() {
        _nicknameAvailable = false;
        _helperMessage = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _checkNicknameAvailability() async {
    final session = AuthSessionStore.instance.session;
    if (session == null) {
      return;
    }

    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      setState(() {
        _errorMessage = '닉네임을 입력해주세요.';
      });
      return;
    }
    final validationMessage = NicknameValidator.validate(nickname);
    if (validationMessage != null) {
      setState(() {
        _errorMessage = validationMessage;
      });
      return;
    }

    setState(() {
      _checking = true;
      _errorMessage = null;
      _helperMessage = null;
    });

    try {
      final available = await _authService.checkNicknameAvailability(
        accessToken: session.accessToken,
        nickname: nickname,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _nicknameAvailable = available;
        _helperMessage = available
            ? '사용할 수 있는 닉네임이에요.'
            : null;
        _errorMessage = available ? null : '이미 사용 중인 닉네임이에요.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.contains('다시 로그인')) {
        await AuthSessionStore.instance.clear();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
        return;
      }
      setState(() {
        _nicknameAvailable = false;
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  Future<void> _saveNickname() async {
    final session = AuthSessionStore.instance.session;
    if (session == null) {
      return;
    }
    final nickname = _nicknameController.text.trim();
    final validationMessage = NicknameValidator.validate(nickname);
    if (validationMessage != null) {
      setState(() {
        _errorMessage = validationMessage;
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = await _authService.updateNickname(
        accessToken: session.accessToken,
        nickname: nickname,
      );
      await AuthSessionStore.instance.save(session.copyWith(user: updatedUser));
      if (!mounted) {
        return;
      }
      _openNext(updatedUser);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.contains('다시 로그인')) {
        await AuthSessionStore.instance.clear();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
        return;
      }
      setState(() {
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _openNext(AuthUser user) {
    final destination = user.hasRiskProfile
        ? const AppShell()
        : const InvestmentDnaSurveyScreen();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

}
