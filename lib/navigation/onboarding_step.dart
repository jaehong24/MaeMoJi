import '../models/auth_user.dart';

enum OnboardingStep { nickname, riskProfileSurvey, app }

OnboardingStep resolveOnboardingStep(AuthUser user) {
  if (!user.nicknameConfirmed) {
    return OnboardingStep.nickname;
  }
  if (!user.hasRiskProfile) {
    return OnboardingStep.riskProfileSurvey;
  }
  return OnboardingStep.app;
}
