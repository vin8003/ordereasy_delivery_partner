/// Thrown when a POD attach/lookup is rejected before touching the store.
class PodValidationException implements Exception {
  const PodValidationException(this.message);

  final String message;

  @override
  String toString() => 'PodValidationException: $message';
}

/// Thrown when the dummy store has no OFD order for the given id.
class PodOrderNotFoundException implements Exception {
  const PodOrderNotFoundException(this.orderId);

  final String orderId;

  @override
  String toString() =>
      'PodOrderNotFoundException: no OFD order with id "$orderId"';
}
