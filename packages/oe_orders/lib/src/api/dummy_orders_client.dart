import '../models/delivery_order.dart';
import 'order_fixtures.dart';
import 'orders_api_config.dart';

/// In-memory dummy API for assigned OFD orders.
///
/// [OrdersApiConfig.baseUrl] is recorded so the rider app can point at a
/// local dummy server later. This client never performs HTTP and never
/// contacts live OrderEasy production hosts.
class DummyOrdersClient {
  DummyOrdersClient({
    OrdersApiConfig? config,
    OrdersFixtureSet fixtureSet = OrdersFixtureSet.assignedOfd,
    List<DeliveryOrder>? orders,
  })  : config = config ?? OrdersApiConfig(),
        _orders = List<DeliveryOrder>.unmodifiable(
          orders ?? OrderFixtures.forSet(fixtureSet),
        );

  factory DummyOrdersClient.fromJsonMaps({
    required List<Map<String, Object?>> assignedOrders,
    OrdersApiConfig? config,
  }) {
    return DummyOrdersClient(
      config: config,
      orders: assignedOrders.map(DeliveryOrder.fromJson).toList(),
    );
  }

  final OrdersApiConfig config;
  final List<DeliveryOrder> _orders;

  String get assignedOrdersUrl => '${config.baseUrl}/rider/orders';

  String orderUrl(String id) => '${config.baseUrl}/rider/orders/$id';

  Future<List<DeliveryOrder>> listAssignedOrders() async {
    return _orders;
  }

  Future<DeliveryOrder?> fetchOrderById(String id) async {
    for (final order in _orders) {
      if (order.id == id) {
        return order;
      }
    }
    return null;
  }
}
