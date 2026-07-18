class FirebaseWebConfig {
  const FirebaseWebConfig._();

  static const String apiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyCwkMfwEiFQ73_kPP8iAs4-4CWnwgQcsSc',
  );

  static const String authDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
    defaultValue: 'maemoji-c4302.firebaseapp.com',
  );

  static const String projectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
    defaultValue: 'maemoji-c4302',
  );

  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
    defaultValue: 'maemoji-c4302.firebasestorage.app',
  );

  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
    defaultValue: '35410209271',
  );

  static const String appId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:35410209271:web:4d6f40d6959cae571426f2',
  );

  static const String measurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
    defaultValue: 'G-W3GMYX8DS7',
  );

  static const String vapidKey = String.fromEnvironment(
    'FIREBASE_WEB_VAPID_KEY',
    defaultValue:
        'BHatBPaXVjYCZyLffvXEWluDmhbAo_RvQUsWJectphNpIIzhR5YILCnwxDlnO76NtSZPQM56Oh6648_IbmIVmcA',
  );

  static bool get hasRequiredOptions =>
      apiKey.trim().isNotEmpty &&
      authDomain.trim().isNotEmpty &&
      projectId.trim().isNotEmpty &&
      storageBucket.trim().isNotEmpty &&
      messagingSenderId.trim().isNotEmpty &&
      appId.trim().isNotEmpty;

  static bool get hasVapidKey => vapidKey.trim().isNotEmpty;
}
