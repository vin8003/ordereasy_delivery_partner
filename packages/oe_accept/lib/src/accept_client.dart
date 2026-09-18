import 'accept_result.dart';

/// Accept or reject an assigned delivery.
abstract class AcceptClient {
  Future<AcceptResult> acceptOrder(String orderId);

  Future<AcceptResult> rejectOrder(String orderId, String reason);
}
