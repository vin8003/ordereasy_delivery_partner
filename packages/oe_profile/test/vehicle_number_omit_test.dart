import 'package:flutter_test/flutter_test.dart';
import 'package:oe_profile/oe_profile.dart';

void main() {
  group('RiderProfile optional vehicle_number omit', () {
    test('toJson omits vehicle_number when it is null', () {
      final profile = RiderProfile(
        name: 'Asha Kumar',
        phone: '+919876543210',
        isOnline: true,
      );

      expect(profile.vehicleNumber, isNull);
      expect(profile.toJson().containsKey('vehicle_number'), isFalse);
      expect(profile.toJson().containsKey('vehicleNumber'), isFalse);
    });

    test('toJson omits vehicle_number when it is empty', () {
      final profile = RiderProfile(
        name: 'Asha Kumar',
        phone: '+919876543210',
        vehicleNumber: '',
        isOnline: false,
      );

      expect(profile.vehicleNumber, isNull);
      expect(profile.toJson().containsKey('vehicle_number'), isFalse);
      expect(
        profile,
        RiderProfile(
          name: 'Asha Kumar',
          phone: '+919876543210',
          isOnline: false,
        ),
      );
    });

    test('constructor treats whitespace-only vehicle_number as omitted', () {
      final profile = RiderProfile(
        name: 'Asha Kumar',
        phone: '+919876543210',
        vehicleNumber: '   ',
        isOnline: true,
      );

      expect(profile.vehicleNumber, isNull);
      expect(profile.toJson().containsKey('vehicle_number'), isFalse);
    });

    test('fromJson treats whitespace-only vehicle_number as omitted', () {
      final profile = RiderProfile.fromJson(const {
        'name': 'Asha Kumar',
        'phone': '+919876543210',
        'vehicle_number': '   ',
        'online': true,
      });

      expect(profile.vehicleNumber, isNull);
      expect(profile.toJson().containsKey('vehicle_number'), isFalse);
    });

    test('toJson includes vehicle_number when present', () {
      final profile = RiderProfile(
        name: 'Asha Kumar',
        phone: '+919876543210',
        vehicleNumber: 'DL01AB1234',
        isOnline: true,
      );

      expect(profile.toJson()['vehicle_number'], 'DL01AB1234');
    });

    test('fromJson treats missing vehicle_number as omitted', () {
      final profile = RiderProfile.fromJson(const {
        'name': 'Asha Kumar',
        'phone': '+919876543210',
        'online': true,
      });

      expect(profile.vehicleNumber, isNull);
      expect(profile.toJson().containsKey('vehicle_number'), isFalse);
    });

    test('fromJson treats explicit null vehicle_number as omitted', () {
      final profile = RiderProfile.fromJson(const {
        'name': 'Asha Kumar',
        'phone': '+919876543210',
        'vehicle_number': null,
        'online': false,
      });

      expect(profile.vehicleNumber, isNull);
      expect(profile.toJson().containsKey('vehicle_number'), isFalse);
    });

    test('fromJson treats empty vehicle_number as omitted', () {
      final profile = RiderProfile.fromJson(const {
        'name': 'Asha Kumar',
        'phone': '+919876543210',
        'vehicle_number': '',
        'online': false,
      });

      expect(profile.vehicleNumber, isNull);
      expect(profile.toJson().containsKey('vehicle_number'), isFalse);
    });

    test('fromJson reads snake_case vehicle_number', () {
      final profile = RiderProfile.fromJson(const {
        'name': 'Ravi',
        'phone': '9000000000',
        'vehicle_number': 'MH12CD5678',
        'online': true,
      });

      expect(profile.vehicleNumber, 'MH12CD5678');
    });

    test('fromJson reads camelCase vehicleNumber and isOnline aliases', () {
      final profile = RiderProfile.fromJson(const {
        'name': 'Ravi',
        'phone': '9000000000',
        'vehicleNumber': 'KA03EF9012',
        'isOnline': true,
      });

      expect(profile.vehicleNumber, 'KA03EF9012');
      expect(profile.isOnline, isTrue);
    });

    test('fromJson reads is_online alias', () {
      final profile = RiderProfile.fromJson(const {
        'name': 'Ravi',
        'phone': '9000000000',
        'is_online': false,
      });

      expect(profile.isOnline, isFalse);
      expect(profile.vehicleNumber, isNull);
    });

    test('round-trip keeps omitted vehicle_number omitted', () {
      final restored = RiderProfile.fromJson(
        RiderProfile(
          name: 'Asha Kumar',
          phone: '+919876543210',
          isOnline: true,
        ).toJson(),
      );

      expect(restored.vehicleNumber, isNull);
      expect(restored.toJson().containsKey('vehicle_number'), isFalse);
    });
  });
}
