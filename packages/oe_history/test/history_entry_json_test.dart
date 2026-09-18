import 'package:oe_history/oe_history.dart';
import 'package:test/test.dart';

void main() {
  group('HistoryStatus', () {
    test('maps only completed wire values delivered and delivery_failed', () {
      expect(HistoryStatus.fromJson('delivered'), HistoryStatus.delivered);
      expect(
        HistoryStatus.fromJson('delivery_failed'),
        HistoryStatus.deliveryFailed,
      );
      expect(
        HistoryStatus.values.map((s) => s.wireValue).toSet(),
        {'delivered', 'delivery_failed'},
      );
    });

    test('toJson emits the API wire value', () {
      expect(HistoryStatus.delivered.toJson(), 'delivered');
      expect(HistoryStatus.deliveryFailed.toJson(), 'delivery_failed');
    });

    test('rejects assigned OFD status used by oe_orders', () {
      expect(
        () => HistoryStatus.fromJson('out_for_delivery'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unknown status strings', () {
      expect(
        () => HistoryStatus.fromJson('packed'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('HistoryEntry.fromJson / toJson', () {
    test('parses a full camelCase delivered payload', () {
      final entry = HistoryEntry.fromJson(const {
        'id': 'hist-2001',
        'status': 'delivered',
        'address': '12 MG Road, Bengaluru 560001',
        'customerName': 'Asha Rao',
        'itemsSummary': '2 items · Idli, Filter coffee',
        'completedAt': '2026-09-18T10:30:00.000Z',
      });

      expect(entry.id, 'hist-2001');
      expect(entry.status, HistoryStatus.delivered);
      expect(entry.address, '12 MG Road, Bengaluru 560001');
      expect(entry.customerName, 'Asha Rao');
      expect(entry.itemsSummary, '2 items · Idli, Filter coffee');
      expect(entry.completedAt, DateTime.utc(2026, 9, 18, 10, 30));
      expect(entry.failureReason, isNull);
    });

    test('parses snake_case aliases for a failed delivery', () {
      final entry = HistoryEntry.fromJson(const {
        'id': 'hist-2003',
        'status': 'delivery_failed',
        'address': '88 Koramangala 4th Block, Bengaluru 560034',
        'customer_name': 'Imran Khan',
        'items_summary': '1 item · Paneer roll',
        'completed_at': '2026-09-18T14:05:00.000Z',
        'failure_reason': 'Customer unavailable',
      });

      expect(entry.customerName, 'Imran Khan');
      expect(entry.itemsSummary, '1 item · Paneer roll');
      expect(entry.status, HistoryStatus.deliveryFailed);
      expect(entry.completedAt, DateTime.utc(2026, 9, 18, 14, 5));
      expect(entry.failureReason, 'Customer unavailable');
    });

    test('allows omitted optional customerName and failureReason', () {
      final entry = HistoryEntry.fromJson(const {
        'id': 'hist-2004',
        'status': 'delivered',
        'address': 'Gate 2, Indiranagar Metro, Bengaluru 560038',
        'itemsSummary': '3 items · Dosa, Vada, Chutney',
        'completedAt': '2026-09-17T18:40:00.000Z',
      });

      expect(entry.customerName, isNull);
      expect(entry.failureReason, isNull);
      expect(entry.status, HistoryStatus.delivered);
    });

    test('round-trips through toJson', () {
      final original = HistoryEntry(
        id: 'hist-2001',
        status: HistoryStatus.delivered,
        address: '12 MG Road, Bengaluru 560001',
        customerName: 'Asha Rao',
        itemsSummary: '2 items · Idli, Filter coffee',
        completedAt: DateTime.utc(2026, 9, 18, 10, 30),
      );

      final encoded = original.toJson();
      expect(encoded, {
        'id': 'hist-2001',
        'status': 'delivered',
        'address': '12 MG Road, Bengaluru 560001',
        'customerName': 'Asha Rao',
        'itemsSummary': '2 items · Idli, Filter coffee',
        'completedAt': '2026-09-18T10:30:00.000Z',
      });

      expect(
        HistoryEntry.fromJson(Map<String, Object?>.from(encoded)),
        original,
      );
    });

    test('omits null optional fields from toJson', () {
      final entry = HistoryEntry(
        id: 'hist-2004',
        status: HistoryStatus.delivered,
        address: 'Gate 2, Indiranagar Metro, Bengaluru 560038',
        itemsSummary: '3 items · Dosa, Vada, Chutney',
        completedAt: DateTime.utc(2026, 9, 17, 18, 40),
      );

      expect(entry.toJson().containsKey('customerName'), isFalse);
      expect(entry.toJson().containsKey('failureReason'), isFalse);
    });

    test('rejects missing required fields', () {
      expect(
        () => HistoryEntry.fromJson(const {'status': 'delivered'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => HistoryEntry.fromJson(const {
          'id': '',
          'status': 'delivered',
          'address': 'x',
          'itemsSummary': 'y',
          'completedAt': '2026-09-18T10:30:00.000Z',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects assigned OFD status on a history entry', () {
      expect(
        () => HistoryEntry.fromJson(const {
          'id': 'ofd-1001',
          'status': 'out_for_delivery',
          'address': '12 MG Road, Bengaluru 560001',
          'itemsSummary': '2 items · Idli, Filter coffee',
          'completedAt': '2026-09-18T10:30:00.000Z',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
