/// Rider-facing delivery states for an assigned order.
enum DeliveryOrderStatus {
  outForDelivery('out_for_delivery'),
  delivered('delivered'),
  deliveryFailed('delivery_failed');

  const DeliveryOrderStatus(this.wireValue);

  /// API / JSON wire value.
  final String wireValue;

  String toJson() => wireValue;

  static DeliveryOrderStatus fromJson(String value) {
    for (final status in values) {
      if (status.wireValue == value) {
        return status;
      }
    }
    throw FormatException('Unknown delivery order status: $value');
  }
}
