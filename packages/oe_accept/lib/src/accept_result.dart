/// Dummy accept or reject outcome.
enum AcceptAction { accept, reject }

/// Success/failure returned by [acceptOrder] / [rejectOrder].
class AcceptResult {
  const AcceptResult({
    required this.success,
    required this.orderId,
    required this.action,
    this.reason,
    this.message,
  });

  factory AcceptResult.ok({
    required String orderId,
    required AcceptAction action,
    String? reason,
    String? message,
  }) {
    return AcceptResult(
      success: true,
      orderId: orderId,
      action: action,
      reason: reason,
      message: message ??
          (action == AcceptAction.accept
              ? 'Order accepted'
              : 'Order rejected'),
    );
  }

  factory AcceptResult.fail({
    required String orderId,
    required AcceptAction action,
    String? reason,
    String? message,
  }) {
    return AcceptResult(
      success: false,
      orderId: orderId,
      action: action,
      reason: reason,
      message: message ?? 'Request failed',
    );
  }

  final bool success;
  final String orderId;
  final AcceptAction action;
  final String? reason;
  final String? message;

  @override
  String toString() =>
      'AcceptResult(success: $success, orderId: $orderId, action: $action, '
      'reason: $reason, message: $message)';
}
