import 'delivery_order_status.dart';

/// An order assigned to the rider (list row or detail).
class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.status,
    required this.address,
    required this.itemsSummary,
    this.customerName,
    this.lat,
    this.lng,
  });

  final String id;
  final DeliveryOrderStatus status;
  final String address;
  final String itemsSummary;
  final String? customerName;
  final double? lat;
  final double? lng;

  factory DeliveryOrder.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('DeliveryOrder.id is required');
    }

    final statusRaw = json['status'];
    if (statusRaw is! String) {
      throw const FormatException('DeliveryOrder.status is required');
    }

    final address = json['address'];
    if (address is! String || address.isEmpty) {
      throw const FormatException('DeliveryOrder.address is required');
    }

    final items = json['itemsSummary'] ?? json['items_summary'];
    if (items is! String || items.isEmpty) {
      throw const FormatException('DeliveryOrder.itemsSummary is required');
    }

    final customer = json['customerName'] ?? json['customer_name'];
    if (customer != null && customer is! String) {
      throw const FormatException(
        'DeliveryOrder.customerName must be a string',
      );
    }

    return DeliveryOrder(
      id: id,
      status: DeliveryOrderStatus.fromJson(statusRaw),
      address: address,
      itemsSummary: items,
      customerName: customer as String?,
      lat: _readDouble(json['lat']),
      lng: _readDouble(json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'status': status.toJson(),
      'address': address,
      'itemsSummary': itemsSummary,
      if (customerName != null) 'customerName': customerName,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  static double? _readDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    throw FormatException('Expected a number, got ${value.runtimeType}');
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryOrder &&
        other.id == id &&
        other.status == status &&
        other.address == address &&
        other.itemsSummary == itemsSummary &&
        other.customerName == customerName &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode => Object.hash(
        id,
        status,
        address,
        itemsSummary,
        customerName,
        lat,
        lng,
      );

  @override
  String toString() {
    return 'DeliveryOrder(id: $id, status: ${status.wireValue}, '
        'address: $address, customerName: $customerName, '
        'itemsSummary: $itemsSummary, lat: $lat, lng: $lng)';
  }
}
