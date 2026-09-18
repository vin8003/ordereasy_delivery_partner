/// Thrown when a status transition is rejected before any HTTP call.
class StatusValidationException implements Exception {
  StatusValidationException(this.message);

  final String message;

  @override
  String toString() => 'StatusValidationException: $message';
}

/// Thrown when the OrderEasy status endpoint returns a non-success status.
class StatusHttpException implements Exception {
  StatusHttpException({
    required this.statusCode,
    required this.uri,
    this.body = '',
  });

  final int statusCode;
  final Uri uri;
  final String body;

  @override
  String toString() =>
      'StatusHttpException: HTTP $statusCode at $uri${body.isEmpty ? '' : ' — $body'}';
}
