import 'package:oe_earnings/oe_earnings.dart';
import 'package:test/test.dart';

void main() {
  group('EarningsSummary.fromJson', () {
    test('parses today, week, and currency', () {
      final summary = EarningsSummary.fromJson({
        'today': 450.5,
        'week': 3200,
        'currency': 'INR',
      });

      expect(summary.today, 450.5);
      expect(summary.week, 3200);
      expect(summary.currency, 'INR');
    });

    test('coerces integer amounts to doubles', () {
      final summary = EarningsSummary.fromJson({
        'today': 10,
        'week': 70,
        'currency': 'INR',
      });

      expect(summary.today, 10.0);
      expect(summary.week, 70.0);
    });

    test('round-trips through toJson', () {
      const original = EarningsSummary(
        today: 125.25,
        week: 890.75,
        currency: 'INR',
      );

      final parsed = EarningsSummary.fromJson(original.toJson());

      expect(parsed.today, original.today);
      expect(parsed.week, original.week);
      expect(parsed.currency, original.currency);
    });
  });

  group('EarningLine.fromJson', () {
    test('parses orderId, amount, and completedAt', () {
      final line = EarningLine.fromJson({
        'orderId': 'OE-1001',
        'amount': 85.5,
        'completedAt': '2026-09-18T10:30:00.000Z',
      });

      expect(line.orderId, 'OE-1001');
      expect(line.amount, 85.5);
      expect(
        line.completedAt.toUtc(),
        DateTime.utc(2026, 9, 18, 10, 30),
      );
    });

    test('round-trips through toJson', () {
      final original = EarningLine(
        orderId: 'OE-2002',
        amount: 42,
        completedAt: DateTime.utc(2026, 9, 17, 14, 5, 30),
      );

      final parsed = EarningLine.fromJson(original.toJson());

      expect(parsed.orderId, original.orderId);
      expect(parsed.amount, original.amount);
      expect(parsed.completedAt.toUtc(), original.completedAt.toUtc());
    });
  });
}
