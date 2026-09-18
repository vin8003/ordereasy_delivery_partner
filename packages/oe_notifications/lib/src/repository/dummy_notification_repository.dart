import '../fixtures/notification_fixtures.dart';
import '../models/notification_item.dart';
import '../notification_config.dart';
import 'notification_repository.dart';

/// In-process rider inbox that never performs network I/O.
///
/// [NotificationConfig.baseUrl] is retained for callers and is not contacted.
class DummyNotificationRepository implements NotificationRepository {
  /// Creates a dummy repository seeded with [NotificationFixtures.seed].
  DummyNotificationRepository({
    NotificationConfig? config,
    List<NotificationItem>? items,
  })  : config = config ?? NotificationConfig(),
        _items = List<NotificationItem>.from(
          items ?? NotificationFixtures.seed,
        );

  /// Empty inbox used for empty-state screens and tests.
  factory DummyNotificationRepository.empty({NotificationConfig? config}) {
    return DummyNotificationRepository(
      config: config,
      items: NotificationFixtures.empty,
    );
  }

  /// Configurable origin for a future non-dummy client. Never contacted.
  final NotificationConfig config;

  final List<NotificationItem> _items;

  @override
  Future<List<NotificationItem>> list() async {
    final sorted = List<NotificationItem>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<NotificationItem>.unmodifiable(sorted);
  }

  @override
  Future<NotificationItem> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw ArgumentError.value(id, 'id', 'unknown notification');
    }
    final current = _items[index];
    if (current.read) {
      return current;
    }
    final updated = current.copyWith(read: true);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<int> unreadCount() async {
    return _items.where((item) => !item.read).length;
  }
}
