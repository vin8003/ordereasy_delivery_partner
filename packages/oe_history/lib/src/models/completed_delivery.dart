import '../json_numbers.dart';
import 'earnings_stub.dart';
import 'history_status.dart';

/// A completed delivery shown on the rider history list.
class CompletedDelivery {
  /// Creates a completed-delivery row.
  const CompletedDelivery({
    required this.orderId,
    required this.address,
    required this.status,
    required this.completedAt,
    required this.earnings,
  });

  /// Order identifier shown on the list row.
  final String orderId;

  /// Full drop-off address. Use [addressSnippet] on the list.
  final String address;

  /// Terminal status (`delivered` or `delivery_failed`).
  final HistoryStatus status;

  /// When the stop was completed.
  final DateTime completedAt;

  /// Earnings placeholder for this stop.
  final EarningsStub earnings;

  /// Short address for list tiles. Truncates with an ellipsis when needed.
  String addressSnippet({int maxChars = 48}) {
    final trimmed = address.trim();
    if (trimmed.length <= maxChars) {
      return trimmed;
    }
    final cut = maxChars > 1 ? maxChars - 1 : maxChars;
    return '${trimmed.substring(0, cut).trimRight()}…';
  }

  /// Parses camelCase or snake_case dummy JSON.
  factory CompletedDelivery.fromJson(Map<String, dynamic> json) {
    final orderId = json['orderId'] ?? json['order_id'];
    if (orderId is! String || orderId.isEmpty) {
      throw const FormatException('CompletedDelivery.orderId is required');
    }

    final address = json['address'];
    if (address is! String || address.isEmpty) {
      throw const FormatException('CompletedDelivery.address is required');
    }

    final statusRaw = json['status'];
    if (statusRaw is! String) {
      throw const FormatException('CompletedDelivery.status is required');
    }

    final completedAtRaw = json['completedAt'] ?? json['completed_at'];
    final completedAt = switch (completedAtRaw) {
      DateTime value => value,
      String value => DateTime.parse(value),
      _ => throw const FormatException(
          'CompletedDelivery.completedAt is required',
        ),
    };

    final earningsRaw = json['earnings'];
    final EarningsStub earnings;
    if (earningsRaw is Map) {
      earnings = EarningsStub.fromJson(Map<String, dynamic>.from(earningsRaw));
    } else if (json.containsKey('amount')) {
      earnings = EarningsStub(
        amount: asDouble(json['amount']),
        currency: json['currency'] as String? ?? 'INR',
      );
    } else {
      earnings = const EarningsStub(amount: 0);
    }

    return CompletedDelivery(
      orderId: orderId,
      address: address,
      status: HistoryStatus.fromJson(statusRaw),
      completedAt: completedAt,
      earnings: earnings,
    );
  }

  /// Serializes to camelCase dummy JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'orderId': orderId,
      'address': address,
      'status': status.toJson(),
      'completedAt': completedAt.toUtc().toIso8601String(),
      'earnings': earnings.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedDelivery &&
        other.orderId == orderId &&
        other.address == address &&
        other.status == status &&
        other.completedAt == completedAt &&
        other.earnings == earnings;
  }

  @override
  int get hashCode => Object.hash(
        orderId,
        address,
        status,
        completedAt,
        earnings,
      );
}
