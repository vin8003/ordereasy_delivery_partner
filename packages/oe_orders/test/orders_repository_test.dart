import 'package:oe_orders/oe_orders.dart';
import 'package:test/test.dart';

void main() {
  group('OrdersApiConfig', () {
    test('defaults to loopback dummy host, never a production OrderEasy host', () {
      final config = OrdersApiConfig();
      expect(config.baseUrl, 'http://127.0.0.1:8080');
      expect(config.baseUrl.contains('ordereasy.win'), isFalse);
      expect(OrdersApiConfig.defaultBaseUrl, 'http://127.0.0.1:8080');
    });

    test('accepts an explicit non-production baseUrl', () {
      final config = OrdersApiConfig(baseUrl: 'http://10.0.0.8:9000');
      expect(config.baseUrl, 'http://10.0.0.8:9000');
    });

    test('rejects live OrderEasy production hosts', () {
      final blocked = Uri.https('api.${'ordereasy'}.${'win'}').toString();
      expect(
        () => OrdersApiConfig(baseUrl: blocked),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('OrderFixtures', () {
    test('empty fixture has no assigned orders', () {
      expect(OrderFixtures.empty, isEmpty);
    });

    test('assigned OFD fixture has two to three out_for_delivery orders', () {
      final orders = OrderFixtures.assignedOfd;
      expect(orders.length, inInclusiveRange(2, 3));
      expect(
        orders.every((o) => o.status == DeliveryOrderStatus.outForDelivery),
        isTrue,
      );
      expect(orders.map((o) => o.id).toSet().length, orders.length);
    });
  });

  group('OrdersRepository', () {
    test('happy path lists assigned OFD orders from the dummy client', () async {
      final repository = OrdersRepository(
        client: DummyOrdersClient(
          fixtureSet: OrdersFixtureSet.assignedOfd,
        ),
      );

      final assigned = await repository.listAssignedOrders();
      expect(assigned, OrderFixtures.assignedOfd);
      expect(assigned, isNotEmpty);
      expect(
        assigned.every((o) => o.status == DeliveryOrderStatus.outForDelivery),
        isTrue,
      );
    });

    test('happy path fetches an assigned order by id', () async {
      final expected = OrderFixtures.assignedOfd.first;
      final repository = OrdersRepository(
        client: DummyOrdersClient(
          fixtureSet: OrdersFixtureSet.assignedOfd,
        ),
      );

      final found = await repository.fetchById(expected.id);
      expect(found, expected);
      expect(found!.address, isNotEmpty);
      expect(found.itemsSummary, isNotEmpty);
    });

    test('empty path lists no assigned orders', () async {
      final repository = OrdersRepository(
        client: DummyOrdersClient(fixtureSet: OrdersFixtureSet.empty),
      );

      expect(await repository.listAssignedOrders(), isEmpty);
    });

    test('empty path returns null when fetching an unknown id', () async {
      final repository = OrdersRepository(
        client: DummyOrdersClient(fixtureSet: OrdersFixtureSet.empty),
      );

      expect(await repository.fetchById('ofd-1001'), isNull);
    });

    test('maps JSON payloads through the dummy client', () async {
      final repository = OrdersRepository(
        client: DummyOrdersClient.fromJsonMaps(
          assignedOrders: const [
            {
              'id': 'ofd-json-1',
              'status': 'out_for_delivery',
              'address': '1 Residency Road, Bengaluru',
              'customerName': 'Meera Iyer',
              'itemsSummary': '1 item · Masala dosa',
              'lat': 12.97,
              'lng': 77.60,
            },
          ],
        ),
      );

      final assigned = await repository.listAssignedOrders();
      expect(assigned, hasLength(1));
      expect(assigned.single.id, 'ofd-json-1');
      expect(assigned.single.customerName, 'Meera Iyer');
      expect(
        await repository.fetchById('ofd-json-1'),
        assigned.single,
      );
    });

    test('uses the configurable dummy baseUrl without performing HTTP', () {
      final client = DummyOrdersClient(
        config: OrdersApiConfig(baseUrl: 'http://127.0.0.1:8080'),
      );
      expect(client.config.baseUrl, 'http://127.0.0.1:8080');
      expect(client.assignedOrdersUrl, 'http://127.0.0.1:8080/rider/orders');
      expect(
        client.orderUrl('ofd-1001'),
        'http://127.0.0.1:8080/rider/orders/ofd-1001',
      );
    });
  });
}
