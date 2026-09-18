import 'rider_profile.dart';

/// Loads the rider profile shown on the settings stub.
abstract class ProfileRepository {
  /// Current rider profile.
  Future<RiderProfile> fetchProfile();
}
