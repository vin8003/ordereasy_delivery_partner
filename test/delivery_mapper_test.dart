import 'package:flutter_test/flutter_test.dart';
import 'package:ordereasy_delivery_partner/data/dto/delivery_dto.dart';
import 'package:ordereasy_delivery_partner/data/mappers/delivery_mapper.dart';
import 'package:ordereasy_delivery_partner/domain/models/delivery_status.dart';

void main() {
  group('DeliveryStatus', () {
    test('parses OrderEasy api values', () {
      expect(
        DeliveryStatus.fromApi('out_for_delivery'),
        DeliveryStatus.outForDelivery,
      );
      expect(DeliveryStatus.fromApi('delivered'), DeliveryStatus.delivered);
      expect(
        DeliveryStatus.fromApi('delivery_failed'),
        DeliveryStatus.deliveryFailed,
      );
    });

    test('rejects unknown status', () {
      expect(
        () => DeliveryStatus.fromApi('packed'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('DeliveryDto / mapper', () {
    test('maps json and hides blank optional fields', () {
      final dto = DeliveryDto.fromJson({
        'id': 'ofd-1',
        'order_code': 'OE-1',
        'status': 'out_for_delivery',
        'customer_name': 'Test',
        'customer_phone': '  ',
        'address_line': 'Line 1',
        'landmark': null,
        'city': 'Noida',
        'pincode': '',
        'lat': 1.5,
        'lng': 2.5,
        'item_summary': 'Milk',
        'cod_amount': 100,
        'notes': '',
        'photo_url': null,
        'failure_reason': null,
        'assigned_at': '2026-09-18T08:00:00Z',
      });

      expect(dto.customerPhone, isNull);
      expect(dto.landmark, isNull);
      expect(dto.pincode, isNull);
      expect(dto.notes, isNull);

      final domain = dto.toDomain();
      expect(domain.status, DeliveryStatus.outForDelivery);
      expect(domain.codAmount, 100);
      expect(domain.hasCoordinates, isTrue);
    });

    test('listFromJson maps a list', () {
      final list = DeliveryMapper.listFromJson([
        {
          'id': 'a',
          'order_code': 'OE-A',
          'status': 'delivered',
          'customer_name': 'A',
          'address_line': 'Addr',
          'city': 'Delhi',
          'assigned_at': '2026-09-18T08:00:00Z',
        },
      ]);
      expect(list, hasLength(1));
      expect(list.first.status, 'delivered');
    });
  });

  group('DisplayHelpers', () {
    test('formatAddress skips blank landmark and pincode', () {
      final text = DisplayHelpers.formatAddress(
        addressLine: '12 Main',
        landmark: '  ',
        city: 'Noida',
        pincode: null,
      );
      expect(text, '12 Main, Noida');
    });

    test('formatCod returns null when amount missing', () {
      expect(DisplayHelpers.formatCod(null), isNull);
      expect(DisplayHelpers.formatCod(50), 'COD ₹50');
      expect(DisplayHelpers.formatCod(50.5), 'COD ₹50.50');
    });

    test('nullableText trims blanks to null', () {
      expect(DisplayHelpers.nullableText('  hi '), 'hi');
      expect(DisplayHelpers.nullableText('   '), isNull);
      expect(DisplayHelpers.nullableText(null), isNull);
    });
  });
}
