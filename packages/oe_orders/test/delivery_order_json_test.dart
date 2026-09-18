import 'package:oe_orders/oe_orders.dart';
import 'package:test/test.dart';

void main() {
  group('DeliveryOrderStatus', () {
    test('maps wire values for OFD, delivered, and delivery_failed', () {
      expect(
        DeliveryOrderStatus.fromJson('out_for_delivery'),
        DeliveryOrderStatus.outForDelivery,
      );
      expect(
        DeliveryOrderStatus.fromJson('delivered'),
        DeliveryOrderStatus.delivered,
      );
      expect(
        DeliveryOrderStatus.fromJson('delivery_failed'),
        DeliveryOrderStatus.deliveryFailed,
      );
    });

    test('toJson emits the API wire value', () {
      expect(
        DeliveryOrderStatus.outForDelivery.toJson(),
        'out_for_delivery',
      );
      expect(DeliveryOrderStatus.delivered.toJson(), 'delivered');
      expect(
        DeliveryOrderStatus.deliveryFailed.toJson(),
        'delivery_failed',
      );
    });

    test('rejects unknown status strings', () {
      expect(
        () => DeliveryOrderStatus.fromJson('packed'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('DeliveryOrder.fromJson / toJson', () {
    test('parses a full camelCase payload including optional fields', () {
      final order = DeliveryOrder.fromJson(const {
        'id': 'ofd-1001',
        'status': 'out_for_delivery',
        'address': '12 MG Road, Bengaluru 560001',
        'customerName': 'Asha Rao',
        'itemsSummary': '2 items · Idli, Filter coffee',
        'lat': 12.9716,
        'lng': 77.5946,
      });

      expect(order.id, 'ofd-1001');
      expect(order.status, DeliveryOrderStatus.outForDelivery);
      expect(order.address, '12 MG Road, Bengaluru 560001');
      expect(order.customerName, 'Asha Rao');
      expect(order.itemsSummary, '2 items · Idli, Filter coffee');
      expect(order.lat, closeTo(12.9716, 0.0001));
      expect(order.lng, closeTo(77.5946, 0.0001));
    });

    test('parses snake_case aliases and integer coordinates', () {
      final order = DeliveryOrder.fromJson(const {
        'id': 'ofd-1002',
        'status': 'delivered',
        'address': '88 Koramangala 4th Block, Bengaluru',
        'customer_name': 'Imran Khan',
        'items_summary': '1 item · Paneer roll',
        'lat': 13,
        'lng': 77,
      });

      expect(order.customerName, 'Imran Khan');
      expect(order.itemsSummary, '1 item · Paneer roll');
      expect(order.status, DeliveryOrderStatus.delivered);
      expect(order.lat, 13);
      expect(order.lng, 77);
    });

    test('allows omitted optional customerName, lat, and lng', () {
      final order = DeliveryOrder.fromJson(const {
        'id': 'ofd-1003',
        'status': 'delivery_failed',
        'address': 'Gate 2, Indiranagar Metro, Bengaluru',
        'itemsSummary': '3 items · Dosa, Vada, Chutney',
      });

      expect(order.customerName, isNull);
      expect(order.lat, isNull);
      expect(order.lng, isNull);
      expect(order.status, DeliveryOrderStatus.deliveryFailed);
    });

    test('round-trips through toJson', () {
      const original = DeliveryOrder(
        id: 'ofd-1001',
        status: DeliveryOrderStatus.outForDelivery,
        address: '12 MG Road, Bengaluru 560001',
        customerName: 'Asha Rao',
        itemsSummary: '2 items · Idli, Filter coffee',
        lat: 12.9716,
        lng: 77.5946,
      );

      final encoded = original.toJson();
      expect(encoded, {
        'id': 'ofd-1001',
        'status': 'out_for_delivery',
        'address': '12 MG Road, Bengaluru 560001',
        'customerName': 'Asha Rao',
        'itemsSummary': '2 items · Idli, Filter coffee',
        'lat': 12.9716,
        'lng': 77.5946,
      });

      expect(DeliveryOrder.fromJson(Map<String, Object?>.from(encoded)), original);
    });

    test('omits null optional fields from toJson', () {
      const order = DeliveryOrder(
        id: 'ofd-1003',
        status: DeliveryOrderStatus.outForDelivery,
        address: 'Gate 2, Indiranagar Metro, Bengaluru',
        itemsSummary: '3 items · Dosa, Vada, Chutney',
      );

      expect(order.toJson().containsKey('customerName'), isFalse);
      expect(order.toJson().containsKey('lat'), isFalse);
      expect(order.toJson().containsKey('lng'), isFalse);
    });

    test('rejects missing required fields', () {
      expect(
        () => DeliveryOrder.fromJson(const {'status': 'out_for_delivery'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => DeliveryOrder.fromJson(const {
          'id': '',
          'status': 'out_for_delivery',
          'address': 'x',
          'itemsSummary': 'y',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
