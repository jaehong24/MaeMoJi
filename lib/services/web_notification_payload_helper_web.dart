import 'dart:convert';
import 'package:web/web.dart' as web;

String? consumeWebNotificationPayload() {
  final payload = Uri.base.queryParameters['notificationPayload'];
  if (payload == null || payload.trim().isEmpty) {
    return null;
  }

  try {
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    final parameters = Map<String, List<String>>.from(Uri.base.queryParametersAll)
      ..remove('notificationPayload');
    final cleanedUri = Uri.base.replace(
      query: Uri(queryParameters: parameters).query,
    );
    web.window.history.replaceState(null, '', cleanedUri.toString());
    return decoded;
  } catch (_) {
    return null;
  }
}
