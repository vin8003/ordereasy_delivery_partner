/// Local-only API config for the earnings package.
///
/// Defaults to loopback so the delivery partner app never depends on a remote
/// host while this dummy layer is in place.
class OeEarningsConfig {
  const OeEarningsConfig({this.baseUrl = defaultBaseUrl});

  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  final String baseUrl;
}
