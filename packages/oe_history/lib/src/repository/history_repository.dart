import '../models/completed_delivery.dart';

/// Reads completed deliveries for the rider history list.
///
/// Implementations may be dummy or remote later.
abstract class HistoryRepository {
  /// Completed (terminal) deliveries, unsorted.
  ///
  /// Callers group with [groupCompletedDeliveries].
  Future<List<CompletedDelivery>> fetchCompletedDeliveries();
}
