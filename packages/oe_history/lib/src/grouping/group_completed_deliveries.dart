import '../models/completed_delivery.dart';
import '../models/history_day_group.dart';

/// Groups completed deliveries by UTC calendar date.
///
/// Days are newest-first. Items inside each day are also newest-first.
/// An empty input returns an empty list.
List<HistoryDayGroup> groupCompletedDeliveries(
  Iterable<CompletedDelivery> deliveries,
) {
  if (deliveries.isEmpty) {
    return const <HistoryDayGroup>[];
  }

  final buckets = <DateTime, List<CompletedDelivery>>{};
  for (final delivery in deliveries) {
    final utc = delivery.completedAt.toUtc();
    final day = DateTime.utc(utc.year, utc.month, utc.day);
    buckets.putIfAbsent(day, () => <CompletedDelivery>[]).add(delivery);
  }

  final days = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final day in days)
      HistoryDayGroup(
        date: day,
        deliveries: List<CompletedDelivery>.unmodifiable(
          List<CompletedDelivery>.from(buckets[day]!)
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt)),
        ),
      ),
  ];
}
