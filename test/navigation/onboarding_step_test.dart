import 'package:flutter_test/flutter_test.dart';
import 'package:maemoji/models/auth_user.dart';
import 'package:maemoji/navigation/onboarding_step.dart';

void main() {
  test('new user must confirm a nickname first', () {
    expect(
      resolveOnboardingStep(_user(nicknameConfirmed: false)),
      OnboardingStep.nickname,
    );
  });

  test('nickname-confirmed user without a risk profile must take survey', () {
    expect(
      resolveOnboardingStep(_user(nicknameConfirmed: true)),
      OnboardingStep.riskProfileSurvey,
    );
  });

  test('fully onboarded user enters the app', () {
    expect(
      resolveOnboardingStep(
        _user(
          nicknameConfirmed: true,
          riskProfile: 'BALANCED',
          investmentDnaType: '균형추구형',
        ),
      ),
      OnboardingStep.app,
    );
  });

  test('partial risk profile data never skips the survey', () {
    expect(
      resolveOnboardingStep(
        _user(nicknameConfirmed: true, riskProfile: 'BALANCED'),
      ),
      OnboardingStep.riskProfileSurvey,
    );
  });
}

AuthUser _user({
  required bool nicknameConfirmed,
  String? riskProfile,
  String? investmentDnaType,
}) {
  return AuthUser(
    userId: 1,
    email: 'new-user@example.com',
    nickname: nicknameConfirmed ? '새사용자' : '',
    profileImageUrl: '',
    nicknameConfirmed: nicknameConfirmed,
    riskProfile: riskProfile,
    investmentDnaType: investmentDnaType,
  );
}
