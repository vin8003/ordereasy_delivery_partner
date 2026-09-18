/// Local-only API config for the history package.
///
/// Defaults to loopback. Live OrderEasy hosts and other `*.win` hosts are
/// rejected so this dummy layer cannot accidentally target them.
class HistoryConfig {
  /// Loopback dummy host. This package never performs HTTP.
  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  /// Validates [baseUrl] and stores it for a future real client.
  HistoryConfig({String baseUrl = defaultBaseUrl})
      : baseUrl = requireSafeBaseUrl(baseUrl);

  /// Recorded dummy endpoint. Not used for network I/O.
  final String baseUrl;

  /// Validates [baseUrl] and returns it.
  ///
  /// Throws [ArgumentError] for empty values, live OrderEasy production
  /// hosts, or any host under the production TLD.
  static String requireSafeBaseUrl(String baseUrl) {
    if (baseUrl.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must not be empty');
    }
    final parsed = Uri.tryParse(baseUrl);
    final host = (parsed?.host ?? '').toLowerCase();
    if (_isBlockedHost(host)) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Production hosts are not allowed',
      );
    }
    return baseUrl;
  }

  static bool _isBlockedHost(String host) {
    const tld = 'win';
    const brand = 'ordereasy';
    final blocked = '$brand.$tld';
    if (host == blocked || host.endsWith('.$blocked')) {
      return true;
    }
    return host == tld || host.endsWith('.$tld');
  }
}
