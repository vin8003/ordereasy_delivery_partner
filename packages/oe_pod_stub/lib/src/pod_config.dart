/// Connection settings for a future proof-of-delivery client.
///
/// The default host is loopback. Live OrderEasy production hosts are
/// rejected so this package cannot accidentally target them.
class PodConfig {
  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  PodConfig({String baseUrl = defaultBaseUrl})
      : baseUrl = requireSafeBaseUrl(baseUrl);

  final String baseUrl;

  /// Recorded dummy path for attaching a POD photo to [orderId].
  String attachmentUrl(String orderId) {
    return '$baseUrl/rider/orders/${Uri.encodeComponent(orderId)}/pod';
  }

  /// Validates [baseUrl] and returns it without a trailing slash.
  static String requireSafeBaseUrl(String baseUrl) {
    if (baseUrl.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must not be empty');
    }
    final parsed = Uri.tryParse(baseUrl);
    if (parsed == null || !parsed.hasScheme) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must be an absolute URL');
    }
    final host = parsed.host.toLowerCase();
    if (_isBlockedProductionHost(host)) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Production OrderEasy hosts are not allowed',
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
