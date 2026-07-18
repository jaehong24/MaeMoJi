importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");
importScripts("./firebase-web-config.js");

const config = self.MAE_MOJI_FIREBASE_WEB_CONFIG || {};

const hasRequiredConfig = Boolean(
  config.apiKey &&
    config.authDomain &&
    config.projectId &&
    config.storageBucket &&
    config.messagingSenderId &&
    config.appId,
);

if (hasRequiredConfig) {
  firebase.initializeApp({
    apiKey: config.apiKey,
    authDomain: config.authDomain,
    projectId: config.projectId,
    storageBucket: config.storageBucket,
    messagingSenderId: config.messagingSenderId,
    appId: config.appId,
    measurementId: config.measurementId || undefined,
  });

  const messaging = firebase.messaging();

  messaging.onBackgroundMessage((payload) => {
    const notification = payload.notification || {};
    const data = payload.data || {};
    const title = notification.title || "매모지 알림";
    const options = {
      body: notification.body || "새로운 알림이 도착했어요.",
      icon: "/icons/Icon-192.png",
      badge: "/icons/Icon-192.png",
      data: {
        payloadJson: JSON.stringify(data),
      },
    };

    self.registration.showNotification(title, options);
  });
}

self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  const payloadJson =
    event.notification?.data?.payloadJson ||
    JSON.stringify(event.notification?.data?.FCM_MSG?.data || {});
  if (!payloadJson) {
    event.waitUntil(clients.openWindow("/"));
    return;
  }

  const encodedPayload = btoa(
    unescape(encodeURIComponent(payloadJson)),
  )
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");

  const targetUrl = `/?notificationPayload=${encodedPayload}`;

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ("focus" in client) {
          client.navigate(targetUrl);
          return client.focus();
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }

      return undefined;
    }),
  );
});
