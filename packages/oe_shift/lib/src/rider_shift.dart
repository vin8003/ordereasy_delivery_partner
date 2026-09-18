/// Rider availability and shift clock state.
class RiderShift {
  /// Creates a snapshot of rider availability.
  const RiderShift({
    required this.isOnline,
    required this.isOnShift,
    this.shiftStartedAt,
    this.lastChangedAt,
  });

  /// Offline and off-shift (the dummy default).
  factory RiderShift.idle() =>
      const RiderShift(isOnline: false, isOnShift: false);

  /// Reconstructs a snapshot from [json].
  ///
  /// Accepts camelCase and snake_case keys. A rider marked online is
  /// treated as on-shift even if the shift flag is missing.
  factory RiderShift.fromJson(Map<String, dynamic> json) {
    final isOnline = _readBool(json, 'isOnline', 'is_online');
    final flaggedOnShift = _readBool(json, 'isOnShift', 'is_on_shift');
    return RiderShift(
      isOnline: isOnline,
      isOnShift: isOnline || flaggedOnShift,
      shiftStartedAt: _readTime(json, 'shiftStartedAt', 'shift_started_at'),
      lastChangedAt: _readTime(json, 'lastChangedAt', 'last_changed_at'),
    );
  }

  /// Whether the rider is available for new assignments.
  final bool isOnline;

  /// Whether the rider has an open shift.
  final bool isOnShift;

  /// When the current shift started, if any.
  final DateTime? shiftStartedAt;

  /// When availability or shift last changed.
  final DateTime? lastChangedAt;

  /// Serializes this snapshot using camelCase keys.
  Map<String, dynamic> toJson() => {
        'isOnline': isOnline,
        'isOnShift': isOnShift,
        if (shiftStartedAt != null)
          'shiftStartedAt': shiftStartedAt!.toIso8601String(),
        if (lastChangedAt != null)
          'lastChangedAt': lastChangedAt!.toIso8601String(),
      };

  /// Copy with selected fields replaced.
  RiderShift copyWith({
    bool? isOnline,
    bool? isOnShift,
    DateTime? shiftStartedAt,
    DateTime? lastChangedAt,
    bool clearShiftStartedAt = false,
  }) {
    return RiderShift(
      isOnline: isOnline ?? this.isOnline,
      isOnShift: isOnShift ?? this.isOnShift,
      shiftStartedAt:
          clearShiftStartedAt ? null : (shiftStartedAt ?? this.shiftStartedAt),
      lastChangedAt: lastChangedAt ?? this.lastChangedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RiderShift &&
        other.isOnline == isOnline &&
        other.isOnShift == isOnShift &&
        other.shiftStartedAt == shiftStartedAt &&
        other.lastChangedAt == lastChangedAt;
  }

  @override
  int get hashCode =>
      Object.hash(isOnline, isOnShift, shiftStartedAt, lastChangedAt);

  @override
  String toString() =>
      'RiderShift(isOnline: $isOnline, isOnShift: $isOnShift)';

  static bool _readBool(
    Map<String, dynamic> json,
    String camel,
    String snake,
  ) {
    final value = json[camel] ?? json[snake];
    if (value is bool) {
      return value;
    }
    return false;
  }

  static DateTime? _readTime(
    Map<String, dynamic> json,
    String camel,
    String snake,
  ) {
    final value = json[camel] ?? json[snake];
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toUtc();
    }
    return null;
  }
}
