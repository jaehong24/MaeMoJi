import 'auth_session_store.dart';

class ApiAuthHeaders {
  const ApiAuthHeaders._();

  static Map<String, String> json() {
    return {
      'Content-Type': 'application/json',
      ...AuthSessionStore.instance.authorizationHeaders,
    };
  }

  static Map<String, String> auth() {
    return AuthSessionStore.instance.authorizationHeaders;
  }
}
