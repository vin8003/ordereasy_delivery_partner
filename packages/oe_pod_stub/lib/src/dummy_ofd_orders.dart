import 'ofd_order_ref.dart';

/// Named dummy OFD order sets used by [DummyPodStore].
enum PodFixtureSet {
  empty,
  assignedOfd,
}

/// In-memory dummy OFD orders. Never loaded from a remote host.
abstract final class DummyOfdOrders {
  static const List<OfdOrderRef> empty = <OfdOrderRef>[];

  /// Assigned out-for-delivery ids used by the rider dummy list.
  static const List<OfdOrderRef> assignedOfd = <OfdOrderRef>[
    OfdOrderRef(id: 'ofd-1001'),
    OfdOrderRef(id: 'ofd-1002'),
    OfdOrderRef(id: 'ofd-1003'),
  ];

  static List<OfdOrderRef> forSet(PodFixtureSet set) {
    switch (set) {
      case PodFixtureSet.empty:
        return empty;
      case PodFixtureSet.assignedOfd:
        return assignedOfd;
    }
  }
}
