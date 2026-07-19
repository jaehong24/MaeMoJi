import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> showWebForegroundNotification({
  required String title,
  required String body,
  required String payload,
}) async {
  if (web.Notification.permission != 'granted') {
    return;
  }

  final serviceWorkers = web.window.navigator.serviceWorker;
  final messagingRegistration = await serviceWorkers
      .getRegistration('/firebase-cloud-messaging-push-scope')
      .toDart;
  final registration =
      messagingRegistration ?? await serviceWorkers.ready.toDart;

  await registration
      .showNotification(
        title,
        web.NotificationOptions(
          body: body,
          icon: '/icons/Icon-192.png',
          badge: '/icons/Icon-192.png',
          data: {'payloadJson': payload}.jsify(),
        ),
      )
      .toDart;
}
