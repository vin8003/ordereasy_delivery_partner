import 'package:oe_earnings/oe_earnings.dart';
import 'package:test/test.dart';

void main() {
  group('EarningsSummary.empty', () {
    test('returns zero totals with the default currency', () {
      final summary = EarningsSummary.empty();

      expect(summary.today, 0);
      expect(summary.week, 0);
      expect(summary.currency, 'INR');
    });

    test('accepts an explicit currency', () {
      final summary = EarningsSummary.empty(currency: 'USD');

      expect(summary.today, 0);
      expect(summary.week, 0);
      expect(summary.currency, 'USD');
    });

    test('parses missing or null totals as an empty summary', () {
      final summary = EarningsSummary.fromJson({
        'today': null,
        'currency': 'INR',
      });

      expect(summary.today, 0);
      expect(summary.week, 0);
      expect(summary.currency, 'INR');
    });
  });

  group('DummyEarningsRepository', () {
    test('returns fixture summary and lines', () async {
      final repository = DummyEarningsRepository();

      final summary = await repository.fetchSummary();
      final lines = await repository.fetchLines();

      expect(summary.today, greaterThan(0));
      expect(summary.week, greaterThanOrEqualTo(summary.today));
      expect(summary.currency, isNotEmpty);
      expect(lines, isNotEmpty);
      expect(lines.first.orderId, isNotEmpty);
      expect(lines.first.amount, greaterThan(0));
    });

    test('can return an empty fixture summary', () async {
      final repository = DummyEarningsRepository.empty();

      final summary = await repository.fetchSummary();
      final lines = await repository.fetchLines();

      expect(summary.today, 0);
      expect(summary.week, 0);
      expect(lines, isEmpty);
    });

    test('defaults baseUrl to local loopback', () {
      const config = OeEarningsConfig();

      expect(config.baseUrl, 'http://127.0.0.1:8080');
    });
  });
}
