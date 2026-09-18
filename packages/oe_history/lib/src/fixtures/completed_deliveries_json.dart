import 'dart:convert';

import '../models/completed_delivery.dart';

/// In-memory fixture JSON for [DummyHistoryRepository].
///
/// Spans three UTC days so the history list can show date grouping.
const String completedDeliveriesFixtureJson = '''
[
  {
    "orderId": "OE-1001",
    "address": "12 MG Road, Bengaluru 560001",
    "status": "delivered",
    "completedAt": "2026-09-18T10:30:00.000Z",
    "earnings": { "amount": 85.5, "currency": "INR" }
  },
  {
    "orderId": "OE-1002",
    "address": "88 Koramangala 4th Block, Bengaluru 560034",
    "status": "delivered",
    "completedAt": "2026-09-18T12:05:00.000Z",
    "earnings": { "amount": 120, "currency": "INR" }
  },
  {
    "orderId": "OE-1004",
    "address": "Gate 2, Indiranagar Metro, Bengaluru 560038",
    "status": "delivery_failed",
    "completedAt": "2026-09-17T16:20:00.000Z",
    "earnings": { "amount": 0, "currency": "INR" }
  },
  {
    "orderId": "OE-1003",
    "address": "Palm Grove Society, Delhi 110016",
    "status": "delivered",
    "completedAt": "2026-09-16T18:40:00.000Z",
    "earnings": { "amount": 90, "currency": "INR" }
  }
]
''';

/// Parses a dummy completed-delivery JSON list.
List<CompletedDelivery> parseCompletedDeliveriesJson(String json) {
  final decoded = jsonDecode(json);
  if (decoded is! List) {
    throw const FormatException('Fixture JSON must be a list of deliveries');
  }
  return [
    for (final item in decoded)
      CompletedDelivery.fromJson(Map<String, dynamic>.from(item as Map)),
  ];
}
