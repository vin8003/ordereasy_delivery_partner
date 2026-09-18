import '../fixtures/completed_deliveries_json.dart';
import '../history_config.dart';
import '../models/completed_delivery.dart';
import 'history_repository.dart';

/// In-memory completed-delivery fixtures. Does not perform network I/O.
class DummyHistoryRepository implements HistoryRepository {
  /// Loads [deliveries], or parses [fixtureJson], or the bundled fixture.
  DummyHistoryRepository({
    HistoryConfig? config,
    List<CompletedDelivery>? deliveries,
    String? fixtureJson,
  })  : config = config ?? HistoryConfig(),
        _deliveries = List<CompletedDelivery>.unmodifiable(
          deliveries ??
              parseCompletedDeliveriesJson(
                fixtureJson ?? completedDeliveriesFixtureJson,
              ),
        );

  /// Empty fixture used for the history empty state.
  factory DummyHistoryRepository.empty({HistoryConfig? config}) {
    return DummyHistoryRepository(
      config: config,
      deliveries: const <CompletedDelivery>[],
    );
  }

  /// Recorded dummy config. Never used for HTTP.
  final HistoryConfig config;

  final List<CompletedDelivery> _deliveries;

  @override
  Future<List<CompletedDelivery>> fetchCompletedDeliveries() async {
    return _deliveries;
  }
}
