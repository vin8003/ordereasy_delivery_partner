import 'dummy_ofd_orders.dart';
import 'ofd_order_ref.dart';
import 'pod_attachment.dart';

/// In-memory dummy store of OFD orders and attached POD photo stubs.
class DummyPodStore {
  DummyPodStore({
    Iterable<OfdOrderRef>? orders,
    PodFixtureSet fixtureSet = PodFixtureSet.assignedOfd,
  }) : _orders = {
          for (final order in orders ?? DummyOfdOrders.forSet(fixtureSet))
            order.id: order,
        };

  factory DummyPodStore.empty() =>
      DummyPodStore(fixtureSet: PodFixtureSet.empty);

  final Map<String, OfdOrderRef> _orders;
  final Map<String, PodAttachment> _attachments = {};

  List<OfdOrderRef> get orders => List<OfdOrderRef>.unmodifiable(_orders.values);

  List<PodAttachment> get attachments =>
      List<PodAttachment>.unmodifiable(_attachments.values);

  bool containsOrder(String orderId) => _orders.containsKey(orderId);

  OfdOrderRef? orderById(String orderId) => _orders[orderId];

  void putAttachment(PodAttachment attachment) {
    _attachments[attachment.orderId] = attachment;
  }

  PodAttachment? attachmentFor(String orderId) => _attachments[orderId];
}
