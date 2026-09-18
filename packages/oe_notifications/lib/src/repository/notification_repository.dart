import '../models/notification_item.dart';

/// Rider in-app notification inbox.
///
/// Dummy implementations must not perform network I/O.
abstract class NotificationRepository {
  /// Newest-first inbox rows.
  Future<List<NotificationItem>> list();

  /// Marks [id] as read and returns the updated item.
  Future<NotificationItem> markRead(String id);

  /// Number of unread inbox rows.
  Future<int> unreadCount();
}
