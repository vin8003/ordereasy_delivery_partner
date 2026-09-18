/// Connection settings for the dummy rider-orders API.
///
/// The default host is loopback. Live OrderEasy production hosts are
/// rejected so this package cannot accidentally target them.
class OrdersApiConfig {
  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  OrdersApiConfig({String baseUrl = defaultBaseUrl})
      : baseUrl = requireSafeBaseUrl(baseUrl);

  final String baseUrl;

  /// Validates [baseUrl] and returns it. Throws [ArgumentError] for
  /// live OrderEasy production hosts.
  static String requireSafeBaseUrl(String baseUrl) {
    if (baseUrl.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must not be empty');
    }
    final parsed = Uri.tryParse(baseUrl);
    final host = (parsed?.host ?? '').toLowerCase();
    if (_isBlockedProductionHost(host)) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Production OrderEasy hosts are not allowed',
      );
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
