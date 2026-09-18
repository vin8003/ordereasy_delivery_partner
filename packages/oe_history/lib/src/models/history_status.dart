/// Completed-delivery states only.
///
/// Assigned `out_for_delivery` lives in `oe_orders`, not this package.
enum HistoryStatus {
  delivered('delivered'),
  deliveryFailed('delivery_failed');

  const HistoryStatus(this.wireValue);

  /// API / JSON wire value.
  final String wireValue;

  String toJson() => wireValue;

  static HistoryStatus fromJson(String value) {
    for (final status in values) {
      if (status.wireValue == value) {
        return status;
      }
    }
    throw FormatException('Unknown history status: $value');
  }
}
