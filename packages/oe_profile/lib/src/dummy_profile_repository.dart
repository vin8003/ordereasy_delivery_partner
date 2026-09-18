import 'profile_repository.dart';
import 'rider_profile.dart';

/// In-memory profile fixture. Does not perform network I/O or clear auth.
class DummyProfileRepository implements ProfileRepository {
  /// Creates a dummy repository.
  ///
  /// Defaults to [fixture]. Pass [profile] to override, including a
  /// profile that omits [RiderProfile.vehicleNumber].
  DummyProfileRepository({RiderProfile? profile})
      : _profile = profile ?? fixture;

  /// Typical rider used by the stub (includes a vehicle number).
  static final RiderProfile fixture = RiderProfile(
    name: 'Asha Kumar',
    phone: '+919876543210',
    vehicleNumber: 'DL01AB1234',
    isOnline: true,
  );

  /// Same rider as [fixture], with `vehicle_number` omitted.
  static final RiderProfile fixtureWithoutVehicle = RiderProfile(
    name: 'Asha Kumar',
    phone: '+919876543210',
    isOnline: true,
  );

  final RiderProfile _profile;

  @override
  Future<RiderProfile> fetchProfile() async => _profile;
}
