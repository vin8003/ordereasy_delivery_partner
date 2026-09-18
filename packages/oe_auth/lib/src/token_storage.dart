import 'package:shared_preferences/shared_preferences.dart';

/// Persists the access token only.
abstract class TokenStorage {
  /// Writes [token], replacing any previous value.
  Future<void> write(String token);

  /// Returns the stored token, or `null` if none.
  Future<String?> read();

  /// Removes the stored token.
  Future<void> clear();
}

/// Process-local token store. Useful in tests and as the dummy default.
class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  /// Creates an empty in-memory store.
  InMemoryTokenStorage();

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> clear() async => _token = null;
}

/// [TokenStorage] backed by `shared_preferences`.
class SharedPreferencesTokenStorage implements TokenStorage {
  /// Preference key used when none is supplied.
  static const String defaultKey = 'oe_auth.access_token';

  final SharedPreferences? _prefs;
  final String _key;

  /// Creates a store. Pass [prefs] to inject a pre-loaded instance (tests).
  SharedPreferencesTokenStorage({
    SharedPreferences? prefs,
    String key = defaultKey,
  })  : _prefs = prefs,
        _key = key;

  Future<SharedPreferences> _ready() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<void> write(String token) async {
    await (await _ready()).setString(_key, token);
  }

  @override
  Future<String?> read() async => (await _ready()).getString(_key);

  @override
  Future<void> clear() async {
    await (await _ready()).remove(_key);
  }
}
