import '../models/notification_item.dart';

/// In-memory dummy inbox payloads. Never loaded from a remote host.
abstract final class NotificationFixtures {
  /// Seed inbox used by [DummyNotificationRepository] by default.
  ///
  /// Three unread rider alerts plus one already-read earnings note.
  static final List<NotificationItem> seed = <NotificationItem>[
    NotificationItem(
      id: 'ntf-1004',
      title: 'New delivery assigned',
      body: 'Order OFD-1004 is ready for pickup at Koramangala Hub.',
      createdAt: DateTime.utc(2026, 9, 18, 14, 5),
    ),
    NotificationItem(
      id: 'ntf-1003',
      title: 'COD reminder',
      body: 'Collect ₹240 cash for order OFD-1002 at delivery.',
      createdAt: DateTime.utc(2026, 9, 18, 12, 40),
    ),
    NotificationItem(
      id: 'ntf-1002',
      title: 'Shift starts soon',
      body: 'Your evening shift begins at 17:00. Go online when ready.',
      createdAt: DateTime.utc(2026, 9, 18, 11, 15),
    ),
    NotificationItem(
      id: 'ntf-1001',
      title: 'Weekly earnings settled',
      body: '₹2,450 was credited for last week’s completed deliveries.',
      createdAt: DateTime.utc(2026, 9, 17, 9, 0),
      read: true,
    ),
  ];

  /// Empty inbox for empty-state screens and tests.
  static const List<NotificationItem> empty = <NotificationItem>[];
}
