import '../../domain/models/delivery.dart';
import '../../domain/models/delivery_status.dart';

/// Raw DTO matching the dummy API JSON contract.
class DeliveryDto {
  const DeliveryDto({
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
  final String status;
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
  final String assignedAt;

  factory DeliveryDto.fromJson(Map<String, dynamic> json) {
    return DeliveryDto(
      id: json['id'] as String,
      orderCode: json['order_code'] as String,
      status: json['status'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: _blankToNull(json['customer_phone'] as String?),
      addressLine: json['address_line'] as String,
      landmark: _blankToNull(json['landmark'] as String?),
      city: json['city'] as String,
      pincode: _blankToNull(json['pincode'] as String?),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      itemSummary: _blankToNull(json['item_summary'] as String?),
      codAmount: (json['cod_amount'] as num?)?.toDouble(),
      notes: _blankToNull(json['notes'] as String?),
      photoUrl: _blankToNull(json['photo_url'] as String?),
      failureReason: _blankToNull(json['failure_reason'] as String?),
      assignedAt: json['assigned_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_code': orderCode,
      'status': status,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address_line': addressLine,
      'landmark': landmark,
      'city': city,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
      'item_summary': itemSummary,
      'cod_amount': codAmount,
      'notes': notes,
      'photo_url': photoUrl,
      'failure_reason': failureReason,
      'assigned_at': assignedAt,
    };
  }

  Delivery toDomain() {
    return Delivery(
      id: id,
      orderCode: orderCode,
      status: DeliveryStatus.fromApi(status),
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
      notes: notes,
      photoUrl: photoUrl,
      failureReason: failureReason,
      assignedAt: DateTime.parse(assignedAt).toLocal(),
    );
  }

  static String? _blankToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
