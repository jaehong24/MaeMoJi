class GoogleAuthConfig {
  const GoogleAuthConfig._();

  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '868949164440-fph4vc0lnrdi3src47alvid1qg1vp930.apps.googleusercontent.com',
  );
}
