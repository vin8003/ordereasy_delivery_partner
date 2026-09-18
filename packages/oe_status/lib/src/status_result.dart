/// Successful mark-delivered / mark-failed response.
class StatusResult {
  const StatusResult({
    required this.orderId,
    required this.status,
    this.reason,
    this.note,
    this.photoPath,
    this.statusCode = 200,
  });

  final String orderId;
  final String status;
  final String? reason;
  final String? note;
  final String? photoPath;
  final int statusCode;

  bool get isDelivered => status == 'delivered';
  bool get isFailed => status == 'delivery_failed';
}
