import '../json_numbers.dart';

/// A single completed-order earning.
class EarningLine {
  const EarningLine({
    required this.orderId,
    required this.amount,
    required this.completedAt,
  });

  final String orderId;
  final double amount;
  final DateTime completedAt;

  factory EarningLine.fromJson(Map<String, dynamic> json) {
    final completedAtRaw = json['completedAt'];
    return EarningLine(
      orderId: json['orderId'] as String? ?? '',
      amount: asDouble(json['amount']),
      completedAt: completedAtRaw is DateTime
          ? completedAtRaw
          : DateTime.parse(completedAtRaw as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'orderId': orderId,
      'amount': amount,
      'completedAt': completedAt.toUtc().toIso8601String(),
    };
  }
}
