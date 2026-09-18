/// Minimal self-contained order handle (`{id}` only).
///
/// Prefer this over depending on `oe_orders`. The app can map an
/// `oe_orders` model to [OrderRef] when wiring packages together.
class OrderRef {
  const OrderRef({required this.id});

  final String id;

  @override
  bool operator ==(Object other) => other is OrderRef && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OrderRef($id)';
}
