/// Terminal rider-facing states shown on completed-delivery history.
enum HistoryStatus {
  /// Order was marked delivered.
  delivered('delivered', 'Delivered'),

  /// Order was marked delivery_failed.
  deliveryFailed('delivery_failed', 'Delivery failed');

  /// Creates a status from its API wire value and list label.
  const HistoryStatus(this.wireValue, this.label);

  /// API / JSON wire value (`delivered` or `delivery_failed`).
  final String wireValue;

  /// Rider-facing label used on [HistoryListScreen] rows.
  final String label;

  /// Serializes to the OrderEasy wire value.
  String toJson() => wireValue;

  /// Parses a wire value. Unknown values throw [FormatException].
  static HistoryStatus fromJson(String value) {
    for (final status in values) {
      if (status.wireValue == value) {
        return status;
      }
    }
    throw FormatException('Unknown completed-delivery status: $value');
  }
}
