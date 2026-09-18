import '../models/delivery_order.dart';
import '../models/delivery_order_status.dart';

/// Named dummy data sets used by [DummyOrdersClient].
enum OrdersFixtureSet {
  empty,
  assignedOfd,
}

/// In-memory dummy payloads. Never loaded from a remote host.
abstract final class OrderFixtures {
  static const List<DeliveryOrder> empty = <DeliveryOrder>[];

  /// Two to three assigned out-for-delivery orders for the rider list.
  static const List<DeliveryOrder> assignedOfd = <DeliveryOrder>[
    DeliveryOrder(
      id: 'ofd-1001',
      status: DeliveryOrderStatus.outForDelivery,
      address: '12 MG Road, Bengaluru 560001',
      customerName: 'Asha Rao',
      itemsSummary: '2 items · Idli, Filter coffee',
      lat: 12.9716,
      lng: 77.5946,
    ),
    DeliveryOrder(
      id: 'ofd-1002',
      status: DeliveryOrderStatus.outForDelivery,
      address: '88 Koramangala 4th Block, Bengaluru 560034',
      customerName: 'Imran Khan',
      itemsSummary: '1 item · Paneer roll',
    ),
    DeliveryOrder(
      id: 'ofd-1003',
      status: DeliveryOrderStatus.outForDelivery,
      address: 'Gate 2, Indiranagar Metro, Bengaluru 560038',
      itemsSummary: '3 items · Dosa, Vada, Chutney',
      lat: 12.9784,
      lng: 77.6408,
    ),
  ];

  static List<DeliveryOrder> forSet(OrdersFixtureSet set) {
    switch (set) {
      case OrdersFixtureSet.empty:
        return empty;
      case OrdersFixtureSet.assignedOfd:
        return assignedOfd;
    }
  }
}
