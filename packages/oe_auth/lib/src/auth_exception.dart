/// Failure from an [AuthRepository] operation.
class AuthException implements Exception {
  /// Human-readable reason.
  final String message;

  /// Creates an auth failure with [message].
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Thrown when the supplied OTP does not match the dummy (or real) code.
class InvalidOtpException extends AuthException {
  /// Creates an invalid-OTP failure.
  const InvalidOtpException([super.message = 'Invalid OTP']);
}
