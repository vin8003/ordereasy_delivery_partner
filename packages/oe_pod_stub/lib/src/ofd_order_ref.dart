/// Minimal self-contained OFD order handle (`{id, status}`).
///
/// Prefer this over depending on `oe_orders`. The app can pass that order's
/// id into [DummyPodClient.attach] when wiring packages.
class OfdOrderRef {
  const OfdOrderRef({
    required this.id,
    this.status = outForDelivery,
  });

  static const outForDelivery = 'out_for_delivery';

  final String id;
  final String status;

  factory OfdOrderRef.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('OfdOrderRef.id is required');
    }
    final status = json['status'] ?? outForDelivery;
    if (status is! String || status.isEmpty) {
      throw const FormatException('OfdOrderRef.status must be a string');
    }
    return OfdOrderRef(id: id, status: status);
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'status': status,
      };

  @override
  bool operator ==(Object other) =>
      other is OfdOrderRef && other.id == id && other.status == status;

  @override
  int get hashCode => Object.hash(id, status);

  @override
  String toString() => 'OfdOrderRef(id: $id, status: $status)';
}
