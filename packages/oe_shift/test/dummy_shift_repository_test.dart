import 'package:oe_shift/oe_shift.dart';
import 'package:test/test.dart';

void main() {
  late DateTime now;
  late InMemoryShiftStorage memory;
  late DummyShiftRepository repo;

  setUp(() {
    now = DateTime.utc(2026, 9, 18, 10);
    memory = InMemoryShiftStorage();
    repo = DummyShiftRepository(
      config: ShiftConfig(),
      storage: memory,
      now: () => now,
    );
  });

  group('ShiftConfig', () {
    test('defaults baseUrl to loopback :8080, not a live host', () {
      final config = ShiftConfig();
      expect(config.baseUrl, ShiftConfig.defaultBaseUrl);
      expect(config.baseUrl, 'http://127.0.0.1:8080');
      expect(config.baseUrl.contains('ordereasy.win'), isFalse);
      expect(repo.config.baseUrl, ShiftConfig.defaultBaseUrl);
    });

    test('rejects live OrderEasy production hosts', () {
      final liveApex = 'https://${'ordereasy'}.${'win'}';
      final liveApi = 'https://api.${'ordereasy'}.${'win'}';
      expect(() => ShiftConfig(baseUrl: liveApex), throwsArgumentError);
      expect(() => ShiftConfig(baseUrl: liveApi), throwsArgumentError);
      expect(
        () => DummyShiftRepository(config: ShiftConfig(baseUrl: liveApi)),
        throwsArgumentError,
      );
    });

    test('rejects an empty or non-absolute baseUrl', () {
      expect(() => ShiftConfig(baseUrl: ''), throwsArgumentError);
      expect(() => ShiftConfig(baseUrl: 'not-a-url'), throwsArgumentError);
    });

    test('rejects live hosts with a trailing DNS dot', () {
      final liveApexDot = 'https://${'ordereasy'}.${'win'}.';
      final liveApiDot = 'https://api.${'ordereasy'}.${'win'}.';
      expect(() => ShiftConfig(baseUrl: liveApexDot), throwsArgumentError);
      expect(() => ShiftConfig(baseUrl: liveApiDot), throwsArgumentError);
    });
  });

  group('DummyShiftRepository availability', () {
    test('starts offline and off-shift', () async {
      final shift = await repo.current();

      expect(shift.isOnline, isFalse);
      expect(shift.isOnShift, isFalse);
      expect(shift.shiftStartedAt, isNull);
    });

    test('goOnline starts a shift and marks the rider online', () async {
      final shift = await repo.goOnline();

      expect(shift.isOnline, isTrue);
      expect(shift.isOnShift, isTrue);
      expect(shift.shiftStartedAt, now);
      expect(shift.lastChangedAt, now);
      expect(await repo.current(), shift);
    });

    test('goOffline pauses availability without ending the shift', () async {
      await repo.goOnline();
      now = DateTime.utc(2026, 9, 18, 11);

      final shift = await repo.goOffline();

      expect(shift.isOnline, isFalse);
      expect(shift.isOnShift, isTrue);
      expect(shift.shiftStartedAt, DateTime.utc(2026, 9, 18, 10));
      expect(shift.lastChangedAt, now);
    });

    test('goOnline while already on shift keeps the original start time',
        () async {
      await repo.startShift();
      now = DateTime.utc(2026, 9, 18, 12);

      final shift = await repo.goOnline();

      expect(shift.isOnline, isTrue);
      expect(shift.isOnShift, isTrue);
      expect(shift.shiftStartedAt, DateTime.utc(2026, 9, 18, 10));
    });

    test('toggleOnline flips availability', () async {
      final online = await repo.toggleOnline();
      expect(online.isOnline, isTrue);
      expect(online.isOnShift, isTrue);

      final offline = await repo.toggleOnline();
      expect(offline.isOnline, isFalse);
      expect(offline.isOnShift, isTrue);
    });

    test('goOnline then current() are equal when the clock is local', () async {
      final local = DateTime(2026, 9, 18, 10);
      expect(local.isUtc, isFalse);
      final localRepo = DummyShiftRepository(
        storage: InMemoryShiftStorage(),
        now: () => local,
      );

      final written = await localRepo.goOnline();
      expect(written, await localRepo.current());
      expect(written.shiftStartedAt!.isUtc, isTrue);
    });

    test('goOnline / goOffline / endShift are idempotent', () async {
      expect(await repo.goOffline(), RiderShift.idle());
      expect(await repo.endShift(), RiderShift.idle());

      final online = await repo.goOnline();
      expect(await repo.goOnline(), online);
    });
  });

  group('DummyShiftRepository shift toggle', () {
    test('startShift clocks in while remaining offline', () async {
      final shift = await repo.startShift();

      expect(shift.isOnShift, isTrue);
      expect(shift.isOnline, isFalse);
      expect(shift.shiftStartedAt, now);
    });

    test('startShift is idempotent', () async {
      await repo.startShift();
      now = DateTime.utc(2026, 9, 18, 10, 30);

      final again = await repo.startShift();

      expect(again.isOnShift, isTrue);
      expect(again.shiftStartedAt, DateTime.utc(2026, 9, 18, 10));
    });

    test('endShift clocks out and forces offline', () async {
      await repo.goOnline();
      now = DateTime.utc(2026, 9, 18, 18);

      final shift = await repo.endShift();

      expect(shift.isOnline, isFalse);
      expect(shift.isOnShift, isFalse);
      expect(shift.shiftStartedAt, isNull);
      expect(shift.lastChangedAt, now);
    });

    test('toggleShift starts then ends a shift', () async {
      final started = await repo.toggleShift();
      expect(started.isOnShift, isTrue);
      expect(started.isOnline, isFalse);

      await repo.goOnline();
      final ended = await repo.toggleShift();
      expect(ended.isOnShift, isFalse);
      expect(ended.isOnline, isFalse);
    });
  });

  group('dummy persistence', () {
    test('InMemoryShiftStorage survives a new repository instance', () async {
      await repo.goOnline();

      final other = DummyShiftRepository(
        storage: memory,
        now: () => now,
      );
      final restored = await other.current();

      expect(restored.isOnline, isTrue);
      expect(restored.isOnShift, isTrue);
      expect(restored.shiftStartedAt, DateTime.utc(2026, 9, 18, 10));
    });

    test('SharedPrefsShiftStorage stub persists across repository instances',
        () async {
      final prefs = SharedPrefsStub();
      final storage = SharedPrefsShiftStorage(prefs: prefs);
      final first = DummyShiftRepository(
        storage: storage,
        now: () => now,
      );

      await first.startShift();
      await first.goOnline();

      expect(prefs.getString(SharedPrefsShiftStorage.defaultKey), isNotNull);

      final second = DummyShiftRepository(
        storage: SharedPrefsShiftStorage(prefs: prefs),
        now: () => now,
      );
      final restored = await second.current();

      expect(restored.isOnline, isTrue);
      expect(restored.isOnShift, isTrue);
      expect(restored.shiftStartedAt, now);
    });

    test('clearing storage returns the rider to idle', () async {
      await repo.goOnline();
      await memory.clear();

      final shift = await repo.current();
      expect(shift.isOnline, isFalse);
      expect(shift.isOnShift, isFalse);
    });

    test('corrupt stored JSON is treated as idle', () async {
      await memory.write('not-json');
      expect(await repo.current(), RiderShift.idle());
    });
  });
}
