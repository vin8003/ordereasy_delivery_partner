import 'history_status.dart';

/// A completed delivery row (delivered or delivery_failed).
///
/// Self-contained: this is not an `oe_orders` assigned-OFD model.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.status,
    required this.address,
    required this.itemsSummary,
    required this.completedAt,
    this.customerName,
    this.failureReason,
  });

  final String id;
  final HistoryStatus status;
  final String address;
  final String itemsSummary;
  final DateTime completedAt;
  final String? customerName;
  final String? failureReason;

  factory HistoryEntry.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('HistoryEntry.id is required');
    }

    final statusRaw = json['status'];
    if (statusRaw is! String) {
      throw const FormatException('HistoryEntry.status is required');
    }

    final address = json['address'];
    if (address is! String || address.isEmpty) {
      throw const FormatException('HistoryEntry.address is required');
    }

    final items = json['itemsSummary'] ?? json['items_summary'];
    if (items is! String || items.isEmpty) {
      throw const FormatException('HistoryEntry.itemsSummary is required');
    }

    final completedRaw = json['completedAt'] ?? json['completed_at'];
    if (completedRaw is! String || completedRaw.isEmpty) {
      throw const FormatException('HistoryEntry.completedAt is required');
    }

    final customer = json['customerName'] ?? json['customer_name'];
    if (customer != null && customer is! String) {
      throw const FormatException(
        'HistoryEntry.customerName must be a string',
      );
    }

    final reason = json['failureReason'] ?? json['failure_reason'];
    if (reason != null && reason is! String) {
      throw const FormatException(
        'HistoryEntry.failureReason must be a string',
      );
    }

    return HistoryEntry(
      id: id,
      status: HistoryStatus.fromJson(statusRaw),
      address: address,
      itemsSummary: items,
      completedAt: DateTime.parse(completedRaw).toUtc(),
      customerName: customer as String?,
      failureReason: reason as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'status': status.toJson(),
      'address': address,
      'itemsSummary': itemsSummary,
      'completedAt': completedAt.toUtc().toIso8601String(),
      if (customerName != null) 'customerName': customerName,
      if (failureReason != null) 'failureReason': failureReason,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryEntry &&
        other.id == id &&
        other.status == status &&
        other.address == address &&
        other.itemsSummary == itemsSummary &&
        other.completedAt == completedAt &&
        other.customerName == customerName &&
        other.failureReason == failureReason;
  }

  @override
  int get hashCode => Object.hash(
        id,
        status,
        address,
        itemsSummary,
        completedAt,
        customerName,
        failureReason,
      );

  @override
  String toString() {
    return 'HistoryEntry(id: $id, status: ${status.wireValue}, '
        'address: $address, customerName: $customerName, '
        'itemsSummary: $itemsSummary, completedAt: $completedAt, '
        'failureReason: $failureReason)';
  }
}
