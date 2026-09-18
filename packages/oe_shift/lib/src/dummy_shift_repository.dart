import 'dart:convert';

import 'rider_shift.dart';
import 'shift_config.dart';
import 'shift_repository.dart';
import 'shift_storage.dart';

/// In-process shift + availability toggle that never performs network I/O.
///
/// [ShiftConfig.baseUrl] is retained for callers but is not contacted.
/// Persistence defaults to [InMemoryShiftStorage]; inject
/// [SharedPrefsShiftStorage] to keep state in a SharedPreferences-shaped stub.
class DummyShiftRepository implements ShiftRepository {
  /// Creates a dummy repository.
  DummyShiftRepository({
    ShiftConfig? config,
    ShiftStorage? storage,
    DateTime Function()? now,
  })  : config = config ?? ShiftConfig(),
        _storage = storage ?? InMemoryShiftStorage(),
        _now = now ?? DateTime.now;

  @override
  final ShiftConfig config;

  final ShiftStorage _storage;
  final DateTime Function() _now;

  @override
  Future<RiderShift> current() => _read();

  @override
  Future<RiderShift> goOnline() async {
    final current = await _read();
    if (current.isOnline && current.isOnShift) {
      return current;
    }
    final startedAt = current.isOnShift ? current.shiftStartedAt : _now();
    return _write(
      RiderShift(
        isOnline: true,
        isOnShift: true,
        shiftStartedAt: startedAt ?? _now(),
        lastChangedAt: _now(),
      ),
    );
  }

  @override
  Future<RiderShift> goOffline() async {
    final current = await _read();
    if (!current.isOnline) {
      return current;
    }
    return _write(
      current.copyWith(
        isOnline: false,
        lastChangedAt: _now(),
      ),
    );
  }

  @override
  Future<RiderShift> startShift() async {
    final current = await _read();
    if (current.isOnShift) {
      return current;
    }
    final now = _now();
    return _write(
      RiderShift(
        isOnline: false,
        isOnShift: true,
        shiftStartedAt: now,
        lastChangedAt: now,
      ),
    );
  }

  @override
  Future<RiderShift> endShift() async {
    final current = await _read();
    if (!current.isOnShift && !current.isOnline) {
      return current;
    }
    return _write(
      RiderShift(
        isOnline: false,
        isOnShift: false,
        lastChangedAt: _now(),
      ),
    );
  }

  @override
  Future<RiderShift> toggleOnline() async {
    final current = await _read();
    return current.isOnline ? goOffline() : goOnline();
  }

  @override
  Future<RiderShift> toggleShift() async {
    final current = await _read();
    return current.isOnShift ? endShift() : startShift();
  }

  Future<RiderShift> _read() async {
    final encoded = await _storage.read();
    if (encoded == null || encoded.isEmpty) {
      return RiderShift.idle();
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return RiderShift.fromJson(decoded);
      }
      if (decoded is Map) {
        return RiderShift.fromJson(Map<String, dynamic>.from(decoded));
      }
    } on FormatException {
      // Corrupt dummy payload — treat as idle.
    }
    return RiderShift.idle();
  }

  Future<RiderShift> _write(RiderShift shift) async {
    await _storage.write(jsonEncode(shift.toJson()));
    return shift;
  }
}
