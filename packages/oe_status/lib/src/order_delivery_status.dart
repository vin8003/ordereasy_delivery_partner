/// OrderEasy delivery-partner status vocabulary.
///
/// Keep these tokens aligned with OrderEasy (`delivered` | `delivery_failed`).
abstract final class OrderDeliveryStatus {
  static const delivered = 'delivered';
  static const deliveryFailed = 'delivery_failed';

  static const values = <String>[delivered, deliveryFailed];
}
