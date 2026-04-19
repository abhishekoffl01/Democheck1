// Our World — Service Worker
const CACHE = 'our-world-v1';

self.addEventListener('install', e => {
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(clients.claim());
});

// ── PUSH NOTIFICATION HANDLER ──
self.addEventListener('push', e => {
  if (!e.data) return;
  let payload;
  try { payload = e.data.json(); }
  catch { payload = { title: 'Our World', body: e.data.text(), icon: '/favicon.ico' }; }

  const options = {
    body: payload.body || 'Something is waiting for you.',
    icon: payload.icon || '/favicon.ico',
    badge: payload.badge || '/favicon.ico',
    tag: payload.tag || 'our-world',
    renotify: true,
    requireInteraction: false,
    vibrate: [200, 100, 200],
    data: { url: payload.url || '/home.html' },
    actions: [
      { action: 'open', title: 'Open' },
      { action: 'dismiss', title: 'Dismiss' }
    ]
  };

  e.waitUntil(
    self.registration.showNotification(payload.title || 'Our World', options)
  );
});

// ── NOTIFICATION CLICK ──
self.addEventListener('notificationclick', e => {
  e.notification.close();
  if (e.action === 'dismiss') return;

  const url = e.notification.data?.url || '/home.html';
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(clientList => {
      for (const client of clientList) {
        if (client.url.includes('home') && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) return clients.openWindow(url);
    })
  );
});

// ── BACKGROUND SYNC (fallback) ──
self.addEventListener('sync', e => {
  if (e.tag === 'check-messages') {
    // Could poll here but we use Supabase realtime instead
  }
});
