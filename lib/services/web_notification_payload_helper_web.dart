import 'dart:convert';
import 'dart:html' as html;

String? consumeWebNotificationPayload() {
  final payload = Uri.base.queryParameters['notificationPayload'];
  if (payload == null || payload.trim().isEmpty) {
    return null;
  }

  try {
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    final cleanedUri = Uri(
      path: Uri.base.path,
      fragment: Uri.base.fragment.isEmpty ? null : Uri.base.fragment,
    );
    html.window.history.replaceState(null, '', cleanedUri.toString());
    return decoded;
  } catch (_) {
    return null;
  }
}
