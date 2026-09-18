import 'package:flutter_test/flutter_test.dart';
import 'package:oe_notifications/oe_notifications.dart';

void main() {
  group('NotificationItem JSON', () {
    test('round-trips camelCase fields and UTC createdAt', () {
      final item = NotificationItem(
        id: 'ntf-9',
        title: 'Assigned',
        body: 'Pickup at hub',
        createdAt: DateTime.utc(2026, 9, 18, 14, 5),
        read: true,
      );

      final decoded = NotificationItem.fromJson(item.toJson());

      expect(decoded, item);
      expect(decoded.createdAt.isUtc, isTrue);
    });

    test('accepts snake_case created_at', () {
      final item = NotificationItem.fromJson(<String, dynamic>{
        'id': 'ntf-8',
        'title': 'COD',
        'body': 'Collect cash',
        'created_at': '2026-09-18T12:40:00Z',
        'read': false,
      });

      expect(item.id, 'ntf-8');
      expect(item.createdAt, DateTime.utc(2026, 9, 18, 12, 40));
      expect(item.read, isFalse);
    });

    test('rejects missing required fields', () {
      expect(
        () => NotificationItem.fromJson(<String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => NotificationItem.fromJson(<String, dynamic>{
          'id': '',
          'title': 'x',
          'body': 'y',
          'createdAt': '2026-09-18T12:00:00Z',
        }),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => NotificationItem.fromJson(<String, dynamic>{
          'id': 'ntf-1',
          'title': 'x',
          'body': 'y',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
