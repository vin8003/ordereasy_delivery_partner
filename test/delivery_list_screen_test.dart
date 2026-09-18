import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordereasy_delivery_partner/app/providers.dart';
import 'package:ordereasy_delivery_partner/domain/models/delivery.dart';
import 'package:ordereasy_delivery_partner/domain/models/delivery_status.dart';
import 'package:ordereasy_delivery_partner/domain/repositories/auth_repository.dart';
import 'package:ordereasy_delivery_partner/domain/repositories/delivery_repository.dart';
import 'package:ordereasy_delivery_partner/features/deliveries/delivery_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDeliveryRepo implements DeliveryRepository {
  _FakeDeliveryRepo(this.items);

  final List<Delivery> items;

  @override
  Future<List<Delivery>> fetchAssignedDeliveries() async => items;

  @override
  Future<Delivery> fetchDelivery(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Delivery> updateStatus(String id, StatusUpdateRequest request) {
    throw UnimplementedError();
  }
}

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<RiderSession> login({required String phone, required String pin}) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<RiderSession?> restoreSession() async {
    return const RiderSession(
      riderId: 'r1',
      displayName: 'Demo Rider',
      token: 't',
    );
  }
}

Delivery _sample(String id) {
  return Delivery(
    id: id,
    orderCode: 'OE-$id',
    status: DeliveryStatus.outForDelivery,
    customerName: 'Customer $id',
    addressLine: 'Address $id',
    city: 'Noida',
    assignedAt: DateTime.utc(2026, 9, 18, 8),
    itemSummary: 'Items',
  );
}

Future<Widget> _wrap(DeliveryRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
      deliveryRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: DeliveryListScreen()),
  );
}

void main() {
  testWidgets('shows empty state when no OFD deliveries', (tester) async {
    await tester.pumpWidget(await _wrap(_FakeDeliveryRepo(const [])));
    await tester.pumpAndSettle();

    expect(find.text('No out_for_delivery stops'), findsOneWidget);
    expect(find.textContaining('Assigned OFD deliveries'), findsOneWidget);
  });

  testWidgets('shows delivery cards when OFD deliveries present', (tester) async {
    await tester.pumpWidget(
      await _wrap(_FakeDeliveryRepo([_sample('1'), _sample('2')])),
    );
    await tester.pumpAndSettle();

    expect(find.text('No out_for_delivery stops'), findsNothing);
    expect(find.text('OE-1'), findsOneWidget);
    expect(find.text('OE-2'), findsOneWidget);
    expect(find.text('Customer 1'), findsOneWidget);
    expect(find.text('Out for delivery'), findsNWidgets(2));
  });
}
