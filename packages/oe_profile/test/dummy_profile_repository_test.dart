import 'package:flutter_test/flutter_test.dart';
import 'package:oe_profile/oe_profile.dart';

void main() {
  test('DummyProfileRepository returns the fixture profile', () async {
    final repo = DummyProfileRepository();

    final profile = await repo.fetchProfile();

    expect(profile, DummyProfileRepository.fixture);
    expect(profile.name, isNotEmpty);
    expect(profile.phone, isNotEmpty);
  });

  test('DummyProfileRepository can return a profile that omits vehicle_number',
      () async {
    final repo = DummyProfileRepository(
      profile: DummyProfileRepository.fixtureWithoutVehicle,
    );

    final profile = await repo.fetchProfile();

    expect(profile, DummyProfileRepository.fixtureWithoutVehicle);
    expect(profile.vehicleNumber, isNull);
    expect(profile.toJson().containsKey('vehicle_number'), isFalse);
    expect(profile.name, DummyProfileRepository.fixture.name);
    expect(profile.phone, DummyProfileRepository.fixture.phone);
  });
}
