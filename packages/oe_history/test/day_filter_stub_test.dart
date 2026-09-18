import 'package:oe_history/oe_history.dart';
import 'package:test/test.dart';

void main() {
  group('DayFilter stub', () {
    test('all filter has no day query and matches any completedAt', () {
      const filter = DayFilter.all();
      expect(filter.day, isNull);
      expect(filter.queryDay, isNull);
      expect(filter.matches(DateTime.utc(2026, 9, 18, 10, 30)), isTrue);
      expect(filter.matches(DateTime.utc(2020, 1, 1)), isTrue);
    });

    test('on filter uses UTC calendar day and formats YYYY-MM-DD query', () {
      final filter = DayFilter.on(DateTime.utc(2026, 9, 18, 15, 45));
      expect(filter.day, DateTime.utc(2026, 9, 18));
      expect(filter.queryDay, '2026-09-18');
      expect(filter.matches(DateTime.utc(2026, 9, 18, 10, 30)), isTrue);
      expect(filter.matches(DateTime.utc(2026, 9, 18, 23, 59, 59)), isTrue);
      expect(filter.matches(DateTime.utc(2026, 9, 17, 23, 59, 59)), isFalse);
      expect(filter.matches(DateTime.utc(2026, 9, 19)), isFalse);
    });

    test('on() matches the same instant after converting local to UTC', () {
      final local = DateTime(2026, 9, 18, 2, 0);
      final filter = DayFilter.on(local);
      final utc = local.toUtc();

      expect(filter.matches(local), isTrue);
      expect(filter.matches(utc), isTrue);
      expect(filter.day, DateTime.utc(utc.year, utc.month, utc.day));
    });

    test('equal UTC days compare equal', () {
      expect(
        DayFilter.on(DateTime.utc(2026, 9, 18, 10)),
        DayFilter.on(DateTime.utc(2026, 9, 18, 22)),
      );
    });
  });

  group('HistoryRepository day filter stub', () {
    late HistoryRepository repository;

    setUp(() {
      repository = HistoryRepository(
        client: DummyHistoryClient(fixtureSet: HistoryFixtureSet.completed),
      );
    });

    test('no filter returns every completed fixture day', () async {
      final history = await repository.listCompleted();
      final days = history
          .map(
            (e) => DateTime.utc(
              e.completedAt.toUtc().year,
              e.completedAt.toUtc().month,
              e.completedAt.toUtc().day,
            ),
          )
          .toSet();
      expect(days.length, greaterThanOrEqualTo(2));
    });

    test('filters completed fixtures to the selected UTC day', () async {
      final history = await repository.listCompleted(
        filter: DayFilter.on(DateTime.utc(2026, 9, 18)),
      );

      expect(history, isNotEmpty);
      expect(
        history.every((e) {
          final utc = e.completedAt.toUtc();
          return utc.year == 2026 && utc.month == 9 && utc.day == 18;
        }),
        isTrue,
      );
      expect(
        history.any((e) => e.status == HistoryStatus.delivered),
        isTrue,
      );
      expect(
        history.any((e) => e.status == HistoryStatus.deliveryFailed),
        isTrue,
      );
    });

    test('unknown day returns an empty list', () async {
      final history = await repository.listCompleted(
        filter: DayFilter.on(DateTime.utc(2020, 1, 1)),
      );
      expect(history, isEmpty);
    });

    test('records a day query on the dummy URL without HTTP', () {
      final client = DummyHistoryClient();
      expect(client.historyUrl(), 'http://127.0.0.1:8080/rider/history');
      expect(
        client.historyUrl(filter: DayFilter.on(DateTime.utc(2026, 9, 18))),
        'http://127.0.0.1:8080/rider/history?day=2026-09-18',
      );
    });
  });
}
