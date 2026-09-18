/// OrderEasy delivery statuses relevant to the rider app.
enum DeliveryStatus {
  outForDelivery('out_for_delivery'),
  delivered('delivered'),
  deliveryFailed('delivery_failed');

  const DeliveryStatus(this.apiValue);

  final String apiValue;

  static DeliveryStatus fromApi(String value) {
    return DeliveryStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => throw FormatException('Unknown delivery status: $value'),
    );
  }

  String get label {
    switch (this) {
      case DeliveryStatus.outForDelivery:
        return 'Out for delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.deliveryFailed:
        return 'Delivery failed';
    }
  }

  bool get isTerminal =>
      this == DeliveryStatus.delivered || this == DeliveryStatus.deliveryFailed;
}
