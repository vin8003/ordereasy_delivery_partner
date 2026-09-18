/// Isolated dummy in-app notification inbox for OrderEasy riders.
///
/// Depend on this library from other packages. The default
/// [NotificationConfig.baseUrl] is `http://127.0.0.1:8080` — never a live
/// OrderEasy host. [DummyNotificationRepository] never performs network I/O.
library;

export 'src/fixtures/notification_fixtures.dart';
export 'src/models/notification_item.dart';
export 'src/notification_config.dart';
export 'src/repository/dummy_notification_repository.dart';
export 'src/repository/notification_repository.dart';
export 'src/screens/inbox_screen.dart';
