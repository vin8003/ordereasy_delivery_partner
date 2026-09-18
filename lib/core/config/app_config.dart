/// Runtime configuration for the delivery partner app.
///
/// [baseUrl] always defaults to a local dummy host. Never point this at
/// production OrderEasy hosts (e.g. *.ordereasy.win).
class AppConfig {
  const AppConfig({
    this.baseUrl = 'http://127.0.0.1:8080',
    this.useLocalFixtures = true,
  });

  /// Configurable API root. Override via `--dart-define=API_BASE_URL=...`.
  final String baseUrl;

  /// When true, the app serves fixtures in-process (no network).
  /// Set false to hit [baseUrl] over HTTP.
  final bool useLocalFixtures;

  factory AppConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8080',
    );
    const useFixtures = bool.fromEnvironment(
      'USE_LOCAL_FIXTURES',
      defaultValue: true,
    );
    return AppConfig(baseUrl: baseUrl, useLocalFixtures: useFixtures);
  }
}
