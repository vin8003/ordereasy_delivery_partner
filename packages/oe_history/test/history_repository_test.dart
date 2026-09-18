import 'package:oe_history/oe_history.dart';
import 'package:test/test.dart';

void main() {
  group('HistoryApiConfig', () {
    test('defaults to loopback dummy host, never a production OrderEasy host',
        () {
      final config = HistoryApiConfig();
      expect(config.baseUrl, 'http://127.0.0.1:8080');
      expect(config.baseUrl.contains('ordereasy.win'), isFalse);
      expect(HistoryApiConfig.defaultBaseUrl, 'http://127.0.0.1:8080');
    });

    test('accepts an explicit non-production baseUrl', () {
      final config = HistoryApiConfig(baseUrl: 'http://10.0.0.8:9000');
      expect(config.baseUrl, 'http://10.0.0.8:9000');
    });

    test('rejects live OrderEasy production hosts', () {
      final blocked = Uri.https('api.${'ordereasy'}.${'win'}').toString();
      expect(
        () => HistoryApiConfig(baseUrl: blocked),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('HistoryFixtures', () {
    test('empty fixture has no completed deliveries', () {
      expect(HistoryFixtures.empty, isEmpty);
    });

    test('completed fixture mixes delivered and delivery_failed only', () {
      final entries = HistoryFixtures.completed;
      expect(entries.length, greaterThanOrEqualTo(3));
      expect(
        entries.every(
          (e) =>
              e.status == HistoryStatus.delivered ||
              e.status == HistoryStatus.deliveryFailed,
        ),
        isTrue,
      );
      expect(
        entries.any((e) => e.status == HistoryStatus.delivered),
        isTrue,
      );
      expect(
        entries.any((e) => e.status == HistoryStatus.deliveryFailed),
        isTrue,
      );
      expect(entries.map((e) => e.id).toSet().length, entries.length);
    });

    test('completed fixtures cannot be mutated', () {
      expect(
        () => HistoryFixtures.completed.add(HistoryFixtures.completed.first),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('HistoryRepository', () {
    test('happy path lists completed delivered and failed fixtures', () async {
      final repository = HistoryRepository(
        client: DummyHistoryClient(
          fixtureSet: HistoryFixtureSet.completed,
        ),
      );

      final history = await repository.listCompleted();
      expect(history, HistoryFixtures.completed);
      expect(history, isNotEmpty);
      expect(
        history.any((e) => e.status == HistoryStatus.delivered),
        isTrue,
      );
      expect(
        history.any((e) => e.status == HistoryStatus.deliveryFailed),
        isTrue,
      );
    });

    test('happy path fetches a completed entry by id', () async {
      final expected = HistoryFixtures.completed.first;
      final repository = HistoryRepository(
        client: DummyHistoryClient(
          fixtureSet: HistoryFixtureSet.completed,
        ),
      );

      final found = await repository.fetchById(expected.id);
      expect(found, expected);
      expect(found!.address, isNotEmpty);
      expect(found.itemsSummary, isNotEmpty);
    });

    test('empty path lists no completed deliveries', () async {
      final repository = HistoryRepository(
        client: DummyHistoryClient(fixtureSet: HistoryFixtureSet.empty),
      );

      expect(await repository.listCompleted(), isEmpty);
    });

    test('empty path returns null when fetching an unknown id', () async {
      final repository = HistoryRepository(
        client: DummyHistoryClient(fixtureSet: HistoryFixtureSet.empty),
      );

      expect(await repository.fetchById('hist-2001'), isNull);
    });

    test('maps JSON payloads through the dummy client', () async {
      final repository = HistoryRepository(
        client: DummyHistoryClient.fromJsonMaps(
          completed: const [
            {
              'id': 'hist-json-1',
              'status': 'delivered',
              'address': '1 Residency Road, Bengaluru',
              'customerName': 'Meera Iyer',
              'itemsSummary': '1 item · Masala dosa',
              'completedAt': '2026-09-18T09:00:00.000Z',
            },
          ],
        ),
      );

      final history = await repository.listCompleted();
      expect(history, hasLength(1));
      expect(history.single.id, 'hist-json-1');
      expect(history.single.customerName, 'Meera Iyer');
      expect(history.single.status, HistoryStatus.delivered);
      expect(await repository.fetchById('hist-json-1'), history.single);
    });

    test('uses the configurable dummy baseUrl without performing HTTP', () {
      final client = DummyHistoryClient(
        config: HistoryApiConfig(baseUrl: 'http://127.0.0.1:8080'),
      );
      expect(client.config.baseUrl, 'http://127.0.0.1:8080');
      expect(client.historyUrl(), 'http://127.0.0.1:8080/rider/history');
      expect(
        client.entryUrl('hist-2001'),
        'http://127.0.0.1:8080/rider/history/hist-2001',
      );
    });
  });
}
