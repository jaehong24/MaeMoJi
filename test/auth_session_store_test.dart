import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:maemoji/models/auth_session.dart';
import 'package:maemoji/models/auth_user.dart';
import 'package:maemoji/services/auth_session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('손상된 저장 세션을 삭제하고 로그인 화면으로 복구한다', () async {
    final persistence = _MemoryAuthSessionPersistence('{invalid-json');
    final store = AuthSessionStore.forTesting(persistence);

    await store.load();

    expect(store.initialized, isTrue);
    expect(store.session, isNull);
    expect(persistence.value, isNull);
  });

  test('유효한 세션을 저장하고 다시 불러온다', () async {
    final persistence = _MemoryAuthSessionPersistence();
    final store = AuthSessionStore.forTesting(persistence);
    final session = AuthSession(
      accessToken: 'test-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      user: const AuthUser(
        userId: 1,
        email: 'tester@maemoji.local',
        nickname: '테스터',
        profileImageUrl: '',
        nicknameConfirmed: true,
      ),
    );

    await store.save(session);

    final restored = AuthSessionStore.forTesting(persistence);
    await restored.load();
    expect(restored.accessToken, 'test-token');
    final storedJson = jsonDecode(persistence.value!) as Map<String, dynamic>;
    final storedUser = storedJson['user'] as Map<String, dynamic>;
    expect(storedUser['email'], 'tester@maemoji.local');
  });
}

class _MemoryAuthSessionPersistence implements AuthSessionPersistence {
  _MemoryAuthSessionPersistence([this.value]);

  String? value;

  @override
  Future<void> delete() async {
    value = null;
  }

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}
