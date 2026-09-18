import '../filter/day_filter.dart';
import '../models/history_entry.dart';
import 'history_api_config.dart';
import 'history_fixtures.dart';

/// In-memory dummy API for completed delivery history.
///
/// [HistoryApiConfig.baseUrl] is recorded so the rider app can point at a
/// local dummy server later. This client never performs HTTP and never
/// contacts live OrderEasy production hosts.
class DummyHistoryClient {
  DummyHistoryClient({
    HistoryApiConfig? config,
    HistoryFixtureSet fixtureSet = HistoryFixtureSet.completed,
    List<HistoryEntry>? entries,
  })  : config = config ?? HistoryApiConfig(),
        _entries = List<HistoryEntry>.unmodifiable(
          entries ?? HistoryFixtures.forSet(fixtureSet),
        );

  factory DummyHistoryClient.fromJsonMaps({
    required List<Map<String, Object?>> completed,
    HistoryApiConfig? config,
  }) {
    return DummyHistoryClient(
      config: config,
      entries: completed.map(HistoryEntry.fromJson).toList(),
    );
  }

  final HistoryApiConfig config;
  final List<HistoryEntry> _entries;

  String historyUrl({DayFilter? filter}) {
    final base = '${config.baseUrl}/rider/history';
    final day = (filter ?? const DayFilter.all()).queryDay;
    if (day == null) {
      return base;
    }
    return '$base?day=$day';
  }

  String entryUrl(String id) => '${config.baseUrl}/rider/history/$id';

  Future<List<HistoryEntry>> listCompleted({
    DayFilter filter = const DayFilter.all(),
  }) async {
    return _entries
        .where((entry) => filter.matches(entry.completedAt))
        .toList(growable: false);
  }

  Future<HistoryEntry?> fetchById(String id) async {
    for (final entry in _entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }
}
