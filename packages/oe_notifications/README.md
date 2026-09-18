# oe_notifications

Isolated dummy **in-app notification inbox** for OrderEasy delivery-partner
riders.

Other packages can depend on this library without touching the app-root
scaffold or any other `oe_*` package.

## Dummy only

- In-process inbox seeded with rider fixtures. No HTTP.
- `NotificationConfig.baseUrl` defaults to `http://127.0.0.1:8080`.
- Live `*.ordereasy.win` hosts are rejected.

## Public API

```dart
import 'package:oe_notifications/oe_notifications.dart';

final inbox = DummyNotificationRepository(
  config: NotificationConfig(), // baseUrl: http://127.0.0.1:8080
);

final items = await inbox.list();
final unread = await inbox.unreadCount();
await inbox.markRead(items.first.id);

// Empty state:
InboxScreen(repository: DummyNotificationRepository.empty());
```

## Rules

- `list()` is newest-`createdAt` first.
- `markRead` is idempotent for an already-read item.
- `InboxScreen` shows the list, marks a row read on tap, and renders
  "No notifications" when the inbox is empty.
