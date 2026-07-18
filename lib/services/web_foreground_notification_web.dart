import 'package:web/web.dart' as web;

void showWebForegroundNotification({
  required String title,
  required String body,
}) {
  if (web.Notification.permission != 'granted') {
    return;
  }

  web.Notification(
    title,
    web.NotificationOptions(
      body: body,
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
    ),
  );
}
