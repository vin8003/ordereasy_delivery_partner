import '../json_numbers.dart';

/// Rider earnings rollup for today and the current week.
class EarningsSummary {
  const EarningsSummary({
    required this.today,
    required this.week,
    required this.currency,
  });

  /// Total completed earnings for the current local day.
  final double today;

  /// Total completed earnings for the current week.
  final double week;

  /// ISO-4217 currency code, e.g. `INR`.
  final String currency;

  factory EarningsSummary.empty({String currency = 'INR'}) {
    return EarningsSummary(today: 0, week: 0, currency: currency);
  }

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      today: asDouble(json['today']),
      week: asDouble(json['week']),
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'today': today,
      'week': week,
      'currency': currency,
    };
  }
}
