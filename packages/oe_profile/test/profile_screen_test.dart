import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oe_profile/oe_profile.dart';

void main() {
  final withVehicle = RiderProfile(
    name: 'Asha Kumar',
    phone: '+919876543210',
    vehicleNumber: 'DL01AB1234',
    isOnline: true,
  );

  final withoutVehicle = RiderProfile(
    name: 'Ravi Singh',
    phone: '9000000000',
    isOnline: false,
  );

  Future<void> pumpScreen(
    WidgetTester tester, {
    required RiderProfile profile,
    VoidCallback? onLogout,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          profile: profile,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  testWidgets('shows name, phone, vehicle_number, and display-only online flag',
      (tester) async {
    await pumpScreen(tester, profile: withVehicle);

    expect(find.text('Asha Kumar'), findsOneWidget);
    expect(find.text('+919876543210'), findsOneWidget);
    expect(find.text('DL01AB1234'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('omits vehicle_number row when the field is absent',
      (tester) async {
    await pumpScreen(tester, profile: withoutVehicle);

    expect(find.text('Ravi Singh'), findsOneWidget);
    expect(find.text('9000000000'), findsOneWidget);
    expect(find.text('Vehicle number'), findsNothing);
    expect(find.text('Offline'), findsOneWidget);
  });

  testWidgets('omits vehicle_number row when the constructor value is empty',
      (tester) async {
    final emptyVehicle = RiderProfile(
      name: 'Ravi Singh',
      phone: '9000000000',
      vehicleNumber: '',
      isOnline: false,
    );

    await pumpScreen(tester, profile: emptyVehicle);

    expect(find.text('Vehicle number'), findsNothing);
  });

  testWidgets('logout button invokes the callback stub without clearing profile',
      (tester) async {
    var calls = 0;
    await pumpScreen(
      tester,
      profile: withVehicle,
      onLogout: () => calls++,
    );

    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pump();

    expect(calls, 1);
    expect(find.text('Asha Kumar'), findsOneWidget);
    expect(find.text('+919876543210'), findsOneWidget);
  });
}
