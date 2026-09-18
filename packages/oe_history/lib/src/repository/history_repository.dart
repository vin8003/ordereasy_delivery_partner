import '../api/dummy_history_client.dart';
import '../filter/day_filter.dart';
import '../models/history_entry.dart';

/// Reads completed delivery history from a dummy client.
///
/// Isolated from assigned OFD (`oe_orders`).
class HistoryRepository {
  HistoryRepository({DummyHistoryClient? client})
      : _client = client ?? DummyHistoryClient();

  final DummyHistoryClient _client;

  DummyHistoryClient get client => _client;

  Future<List<HistoryEntry>> listCompleted({
    DayFilter filter = const DayFilter.all(),
  }) {
    return _client.listCompleted(filter: filter);
  }

  Future<HistoryEntry?> fetchById(String id) {
    return _client.fetchById(id);
  }
}
