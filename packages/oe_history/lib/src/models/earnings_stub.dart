import '../json_numbers.dart';

/// Per-order earnings placeholder shown on a history row.
class EarningsStub {
  /// Creates an earnings stub. Defaults to INR.
  const EarningsStub({
    required this.amount,
    this.currency = 'INR',
  });

  /// Completed-order earning amount.
  final double amount;

  /// ISO-4217 currency code, e.g. `INR`.
  final String currency;

  /// Rider-facing amount, e.g. `₹85.50`.
  String get formatted {
    final amountText = amount.toStringAsFixed(2);
    if (currency == 'INR') {
      return '₹$amountText';
    }
    return '$currency $amountText';
  }

  /// Parses `{amount, currency}` from dummy JSON.
  factory EarningsStub.fromJson(Map<String, dynamic> json) {
    return EarningsStub(
      amount: asDouble(json['amount']),
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  /// Serializes this stub for fixture round-trips.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'amount': amount,
      'currency': currency,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EarningsStub &&
        other.amount == amount &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(amount, currency);
}
