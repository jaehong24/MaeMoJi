import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'auth_session_store.dart';

Future<void> clearSessionIfUnauthorized(http.Response response) async {
  if (response.statusCode != 401) {
    return;
  }

  await AuthSessionStore.instance.clear();
  throw const ApiException(
    '로그인이 만료되었어요. 다시 로그인해주세요.',
    statusCode: 401,
  );
}
