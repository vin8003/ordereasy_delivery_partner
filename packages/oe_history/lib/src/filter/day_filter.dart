/// In-memory calendar-day filter stub for completed history.
///
/// This does not call a remote host. [queryDay] is recorded so a future
/// HTTP client can send `?day=YYYY-MM-DD`.
class DayFilter {
  const DayFilter.all() : day = null;

  factory DayFilter.on(DateTime day) {
    return DayFilter._(DateTime.utc(day.year, day.month, day.day));
  }

  const DayFilter._(this.day);

  /// UTC date-only instant, or `null` when every completed day is included.
  final DateTime? day;

  /// `YYYY-MM-DD` query stub, or `null` for [DayFilter.all].
  String? get queryDay {
    final selected = day;
    if (selected == null) {
      return null;
    }
    final year = selected.year.toString().padLeft(4, '0');
    final month = selected.month.toString().padLeft(2, '0');
    final dayOfMonth = selected.day.toString().padLeft(2, '0');
    return '$year-$month-$dayOfMonth';
  }

  bool matches(DateTime completedAt) {
    final selected = day;
    if (selected == null) {
      return true;
    }
    final utc = completedAt.toUtc();
    return utc.year == selected.year &&
        utc.month == selected.month &&
        utc.day == selected.day;
  }
}
