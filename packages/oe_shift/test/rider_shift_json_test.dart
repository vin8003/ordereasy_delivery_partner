import 'package:oe_shift/oe_shift.dart';
import 'package:test/test.dart';

void main() {
  test('toJson / fromJson round-trip with camelCase keys', () {
    final original = RiderShift(
      isOnline: true,
      isOnShift: true,
      shiftStartedAt: DateTime.utc(2026, 9, 18, 10),
      lastChangedAt: DateTime.utc(2026, 9, 18, 11),
    );

    final restored = RiderShift.fromJson(original.toJson());

    expect(restored, original);
    expect(original.toJson()['isOnline'], isTrue);
    expect(original.toJson()['isOnShift'], isTrue);
  });

  test('fromJson accepts snake_case aliases', () {
    final restored = RiderShift.fromJson({
      'is_online': false,
      'is_on_shift': true,
      'shift_started_at': '2026-09-18T10:00:00.000Z',
      'last_changed_at': '2026-09-18T10:05:00.000Z',
    });

    expect(restored.isOnline, isFalse);
    expect(restored.isOnShift, isTrue);
    expect(restored.shiftStartedAt, DateTime.utc(2026, 9, 18, 10));
    expect(restored.lastChangedAt, DateTime.utc(2026, 9, 18, 10, 5));
  });

  test('fromJson treats missing flags as idle and normalizes online-only', () {
    expect(RiderShift.fromJson(const {}), RiderShift.idle());

    final normalized = RiderShift.fromJson(const {'isOnline': true});
    expect(normalized.isOnline, isTrue);
    expect(normalized.isOnShift, isTrue);
  });

  test('constructor and copyWith keep online riders on-shift', () {
    final constructed = RiderShift(isOnline: true, isOnShift: false);
    expect(constructed.isOnline, isTrue);
    expect(constructed.isOnShift, isTrue);

    final copied = RiderShift.idle().copyWith(isOnline: true, isOnShift: false);
    expect(copied.isOnline, isTrue);
    expect(copied.isOnShift, isTrue);

    final fromJson = RiderShift.fromJson(const {
      'isOnline': true,
      'isOnShift': false,
    });
    expect(fromJson.isOnShift, isTrue);
  });

  test('local DateTimes normalize to UTC for equality after JSON', () {
    final local = DateTime(2026, 9, 18, 10);
    final original = RiderShift(
      isOnline: true,
      isOnShift: true,
      shiftStartedAt: local,
      lastChangedAt: local,
    );

    expect(original.shiftStartedAt!.isUtc, isTrue);
    expect(RiderShift.fromJson(original.toJson()), original);
  });

  test('fromJson ignores an unparsable timestamp', () {
    final restored = RiderShift.fromJson(const {
      'isOnline': true,
      'shiftStartedAt': 'not-a-date',
    });
    expect(restored.isOnline, isTrue);
    expect(restored.isOnShift, isTrue);
    expect(restored.shiftStartedAt, isNull);
  });
}
