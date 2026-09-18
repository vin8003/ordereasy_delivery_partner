import 'package:flutter_test/flutter_test.dart';
import 'package:oe_history/oe_history.dart';

CompletedDelivery _delivery({
  required String orderId,
  required DateTime completedAt,
  String address = '12 MG Road, Bengaluru 560001',
  HistoryStatus status = HistoryStatus.delivered,
  double amount = 85.5,
}) {
  return CompletedDelivery(
    orderId: orderId,
    address: address,
    status: status,
    completedAt: completedAt,
    earnings: EarningsStub(amount: amount),
  );
}

void main() {
  group('groupCompletedDeliveries', () {
    test('returns no groups for an empty list', () {
      expect(groupCompletedDeliveries(const []), isEmpty);
    });

    test('groups completed deliveries by UTC calendar date', () {
      final groups = groupCompletedDeliveries([
        _delivery(
          orderId: 'OE-1001',
          completedAt: DateTime.utc(2026, 9, 18, 10, 30),
        ),
        _delivery(
          orderId: 'OE-1002',
          completedAt: DateTime.utc(2026, 9, 18, 12, 5),
          amount: 120,
        ),
        _delivery(
          orderId: 'OE-1003',
          completedAt: DateTime.utc(2026, 9, 16, 18, 40),
          amount: 90,
        ),
        _delivery(
          orderId: 'OE-1004',
          completedAt: DateTime.utc(2026, 9, 17, 16, 20),
          status: HistoryStatus.deliveryFailed,
          amount: 0,
        ),
      ]);

      expect(groups, hasLength(3));
      expect(groups.map((g) => g.date), [
        DateTime.utc(2026, 9, 18),
        DateTime.utc(2026, 9, 17),
        DateTime.utc(2026, 9, 16),
      ]);
      expect(groups.map((g) => g.label), [
        '18 Sep 2026',
        '17 Sep 2026',
        '16 Sep 2026',
      ]);
      expect(groups[0].deliveries.map((d) => d.orderId), ['OE-1002', 'OE-1001']);
      expect(groups[1].deliveries.single.orderId, 'OE-1004');
      expect(groups[1].deliveries.single.status, HistoryStatus.deliveryFailed);
      expect(groups[2].deliveries.single.orderId, 'OE-1003');
    });

    test('sorts days and items newest-first', () {
      final groups = groupCompletedDeliveries([
        _delivery(
          orderId: 'older-day',
          completedAt: DateTime.utc(2026, 9, 10, 23, 59),
        ),
        _delivery(
          orderId: 'older-same-day',
          completedAt: DateTime.utc(2026, 9, 18, 8),
        ),
        _delivery(
          orderId: 'newer-same-day',
          completedAt: DateTime.utc(2026, 9, 18, 21),
        ),
      ]);

      expect(groups.first.date, DateTime.utc(2026, 9, 18));
      expect(groups.last.date, DateTime.utc(2026, 9, 10));
      expect(groups.first.deliveries.map((d) => d.orderId), [
        'newer-same-day',
        'older-same-day',
      ]);
    });
  });

  group('CompletedDelivery.addressSnippet', () {
    test('returns the full address when it is already short', () {
      final delivery = _delivery(
        orderId: 'OE-1',
        completedAt: DateTime.utc(2026, 9, 18),
        address: '12 MG Road',
        amount: 10,
      );

      expect(delivery.addressSnippet(), '12 MG Road');
    });

    test('truncates a long address for list display', () {
      final delivery = _delivery(
        orderId: 'OE-long',
        completedAt: DateTime.utc(2026, 9, 18),
        address:
            'Flat 4B, Green Park Residency, Near City Mall, Sector 18, Gurugram 122001',
      );

      final snippet = delivery.addressSnippet();
      expect(snippet.length, lessThan(delivery.address.length));
      expect(snippet.endsWith('…'), isTrue);
      expect(snippet, startsWith('Flat 4B, Green Park Residency'));
    });
  });
}
