/// Settings for auth. Dummy implementations ignore [baseUrl] and never
/// perform network I/O.
class AuthConfig {
  /// Local stub host. Callers may override; do not default to a live host.
  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  /// OTP accepted by [DummyAuthRepository].
  static const String defaultDummyOtp = '123456';

  /// Configurable API origin for a future non-dummy client.
  final String baseUrl;

  /// Stub OTP that [DummyAuthRepository.login] treats as valid.
  final String dummyOtp;

  /// Creates config. [baseUrl] defaults to [defaultBaseUrl].
  const AuthConfig({
    this.baseUrl = defaultBaseUrl,
    this.dummyOtp = defaultDummyOtp,
  });
}
