import 'pod_photo_stub.dart';

/// Stub photo bound to an OFD order id in the dummy store.
class PodAttachment {
  const PodAttachment({
    required this.orderId,
    required this.photo,
    this.attachedAt,
  });

  final String orderId;
  final PodPhotoStub photo;
  final DateTime? attachedAt;

  factory PodAttachment.fromJson(Map<String, Object?> json) {
    final orderId = json['orderId'] ?? json['order_id'];
    if (orderId is! String || orderId.isEmpty) {
      throw const FormatException('PodAttachment.orderId is required');
    }

    final photoRaw = json['photo'];
    if (photoRaw is! Map) {
      throw const FormatException('PodAttachment.photo is required');
    }

    final attachedAt = json['attachedAt'] ?? json['attached_at'];
    return PodAttachment(
      orderId: orderId,
      photo: PodPhotoStub.fromJson(Map<String, Object?>.from(photoRaw)),
      attachedAt: attachedAt == null
          ? null
          : attachedAt is DateTime
              ? attachedAt
              : DateTime.parse(attachedAt as String),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'orderId': orderId,
      'photo': photo.toJson(),
      if (attachedAt != null) 'attachedAt': attachedAt!.toUtc().toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is PodAttachment &&
        other.orderId == orderId &&
        other.photo == photo &&
        other.attachedAt == attachedAt;
  }

  @override
  int get hashCode => Object.hash(orderId, photo, attachedAt);

  @override
  String toString() {
    return 'PodAttachment(orderId: $orderId, photo: $photo, '
        'attachedAt: $attachedAt)';
  }
}
