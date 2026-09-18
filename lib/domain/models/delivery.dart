import 'delivery_status.dart';

/// A stop assigned to the logged-in rider.
class Delivery {
  const Delivery({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.customerName,
    required this.addressLine,
    required this.city,
    required this.assignedAt,
    this.customerPhone,
    this.landmark,
    this.pincode,
    this.lat,
    this.lng,
    this.itemSummary,
    this.codAmount,
    this.notes,
    this.photoUrl,
    this.failureReason,
  });

  final String id;
  final String orderCode;
  final DeliveryStatus status;
  final String customerName;
  final String? customerPhone;
  final String addressLine;
  final String? landmark;
  final String city;
  final String? pincode;
  final double? lat;
  final double? lng;
  final String? itemSummary;
  final double? codAmount;
  final String? notes;
  final String? photoUrl;
  final String? failureReason;
  final DateTime assignedAt;

  bool get hasCoordinates => lat != null && lng != null;

  Delivery copyWith({
    DeliveryStatus? status,
    String? photoUrl,
    String? failureReason,
    String? notes,
  }) {
    return Delivery(
      id: id,
      orderCode: orderCode,
      status: status ?? this.status,
      customerName: customerName,
      customerPhone: customerPhone,
      addressLine: addressLine,
      landmark: landmark,
      city: city,
      pincode: pincode,
      lat: lat,
      lng: lng,
      itemSummary: itemSummary,
      codAmount: codAmount,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      failureReason: failureReason ?? this.failureReason,
      assignedAt: assignedAt,
    );
  }
}

class StatusUpdateRequest {
  const StatusUpdateRequest({
    required this.status,
    this.note,
    this.photoStubPath,
  });

  final DeliveryStatus status;
  final String? note;
  final String? photoStubPath;
}

class RiderSession {
  const RiderSession({
    required this.riderId,
    required this.displayName,
    required this.token,
  });

  final String riderId;
  final String displayName;
  final String token;
}
