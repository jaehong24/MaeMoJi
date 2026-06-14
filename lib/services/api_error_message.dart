import 'dart:convert';

import 'package:http/http.dart' as http;

String readApiErrorMessage(
  http.Response response, {
  required String fallback,
}) {
  try {
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final message = (decoded['message'] ?? '').toString().trim();
    if (message.isNotEmpty && message != 'OK') {
      return message;
    }
  } catch (_) {
    // Non-JSON server errors use the user-friendly fallback below.
  }
  return fallback;
}
