import '../models/history_entry.dart';
import '../models/history_status.dart';

/// Named dummy data sets used by [DummyHistoryClient].
enum HistoryFixtureSet {
  empty,
  completed,
}

/// In-memory dummy payloads. Never loaded from a remote host.
abstract final class HistoryFixtures {
  static const List<HistoryEntry> empty = <HistoryEntry>[];

  /// Mixed delivered / delivery_failed rows across more than one UTC day.
  static final List<HistoryEntry> completed = List<HistoryEntry>.unmodifiable(
    <HistoryEntry>[
      HistoryEntry(
        id: 'hist-2001',
        status: HistoryStatus.delivered,
        address: '12 MG Road, Bengaluru 560001',
        customerName: 'Asha Rao',
        itemsSummary: '2 items · Idli, Filter coffee',
        completedAt: DateTime.utc(2026, 9, 18, 10, 30),
      ),
      HistoryEntry(
        id: 'hist-2002',
        status: HistoryStatus.delivered,
        address: '1 Residency Road, Bengaluru 560025',
        customerName: 'Meera Iyer',
        itemsSummary: '1 item · Masala dosa',
        completedAt: DateTime.utc(2026, 9, 18, 12, 5),
      ),
      HistoryEntry(
        id: 'hist-2003',
        status: HistoryStatus.deliveryFailed,
        address: '88 Koramangala 4th Block, Bengaluru 560034',
        customerName: 'Imran Khan',
        itemsSummary: '1 item · Paneer roll',
        completedAt: DateTime.utc(2026, 9, 18, 14, 5),
        failureReason: 'Customer unavailable',
      ),
      HistoryEntry(
        id: 'hist-2004',
        status: HistoryStatus.delivered,
        address: 'Gate 2, Indiranagar Metro, Bengaluru 560038',
        itemsSummary: '3 items · Dosa, Vada, Chutney',
        completedAt: DateTime.utc(2026, 9, 17, 18, 40),
      ),
      HistoryEntry(
        id: 'hist-2005',
        status: HistoryStatus.deliveryFailed,
        address: '44 Jayanagar 4th Block, Bengaluru 560011',
        customerName: 'Rahul Sen',
        itemsSummary: '2 items · Poori, Sagu',
        completedAt: DateTime.utc(2026, 9, 16, 9, 15),
        failureReason: 'Address not found',
      ),
    ],
  );

  static List<HistoryEntry> forSet(HistoryFixtureSet set) {
    switch (set) {
      case HistoryFixtureSet.empty:
        return empty;
      case HistoryFixtureSet.completed:
        return completed;
    }
  }
}
