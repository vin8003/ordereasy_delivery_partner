import 'completed_delivery.dart';

/// Completed deliveries that share a UTC calendar date.
class HistoryDayGroup {
  /// Creates a date section for the history list.
  const HistoryDayGroup({
    required this.date,
    required this.deliveries,
  });

  /// UTC midnight of the group (year/month/day only).
  final DateTime date;

  /// Items completed on [date], newest first.
  final List<CompletedDelivery> deliveries;

  /// Rider-facing header, e.g. `18 Sep 2026`.
  String get label {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final utc = date.toUtc();
    return '${utc.day} ${months[utc.month - 1]} ${utc.year}';
  }
}
