import '../api/dummy_orders_client.dart';
import '../models/delivery_order.dart';

/// Reads the rider's assigned OFD list and order detail from a dummy client.
class OrdersRepository {
  OrdersRepository({DummyOrdersClient? client})
      : _client = client ?? DummyOrdersClient();

  final DummyOrdersClient _client;

  DummyOrdersClient get client => _client;

  Future<List<DeliveryOrder>> listAssignedOrders() {
    return _client.listAssignedOrders();
  }

  Future<DeliveryOrder?> fetchById(String id) {
    return _client.fetchOrderById(id);
  }
}
