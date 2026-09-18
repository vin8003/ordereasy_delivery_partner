import 'rider_shift.dart';
import 'shift_config.dart';

/// Rider online/offline availability and shift clock-in/out.
abstract class ShiftRepository {
  /// Active configuration (includes [ShiftConfig.baseUrl]).
  ShiftConfig get config;

  /// Latest persisted snapshot, or idle when none is stored.
  Future<RiderShift> current();

  /// Makes the rider available. Starts a shift if none is open.
  Future<RiderShift> goOnline();

  /// Pauses availability without ending the open shift.
  Future<RiderShift> goOffline();

  /// Clocks in. The rider stays offline until [goOnline].
  Future<RiderShift> startShift();

  /// Clocks out and forces the rider offline.
  Future<RiderShift> endShift();

  /// Flips [RiderShift.isOnline] (`goOnline` / `goOffline`).
  Future<RiderShift> toggleOnline();

  /// Flips [RiderShift.isOnShift] (`startShift` / `endShift`).
  Future<RiderShift> toggleShift();
}
