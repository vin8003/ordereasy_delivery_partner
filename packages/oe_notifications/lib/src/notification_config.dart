/// Connection settings for a future non-dummy notifications client.
///
/// Dummy implementations keep [baseUrl] for callers and never perform
/// network I/O. Live OrderEasy production hosts are rejected.
class NotificationConfig {
  /// Local stub host. Callers may override; do not default to a live host.
  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  /// Creates config. [baseUrl] defaults to [defaultBaseUrl].
  NotificationConfig({String baseUrl = defaultBaseUrl})
      : baseUrl = requireSafeBaseUrl(baseUrl);

  /// Configurable API origin for a future non-dummy client.
  final String baseUrl;

  /// Validates [baseUrl] and returns it without a trailing slash.
  ///
  /// Throws [ArgumentError] for empty, non-absolute, or live OrderEasy hosts.
  static String requireSafeBaseUrl(String baseUrl) {
    if (baseUrl.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must not be empty');
    }
    final parsed = Uri.tryParse(baseUrl);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'must be an absolute URL',
      );
    }
    final host = parsed.host.toLowerCase();
    if (_isBlockedProductionHost(host)) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'must not use a live OrderEasy host; default is $defaultBaseUrl',
      );
    }
    if (baseUrl.length > 1 && baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }

  static bool _isBlockedProductionHost(String host) {
    const tld = 'win';
    const brand = 'ordereasy';
    final blocked = '$brand.$tld';
    return host == blocked || host.endsWith('.$blocked');
  }
}
