/// Persists an encoded [RiderShift] snapshot.
abstract class ShiftStorage {
  /// Writes [encoded], replacing any previous value.
  Future<void> write(String encoded);

  /// Returns the stored snapshot, or `null` if none.
  Future<String?> read();

  /// Removes the stored snapshot.
  Future<void> clear();
}

/// Process-local store. Useful in tests and as the dummy default.
class InMemoryShiftStorage implements ShiftStorage {
  String? _encoded;

  /// Creates an empty in-memory store.
  InMemoryShiftStorage();

  @override
  Future<void> write(String encoded) async => _encoded = encoded;

  @override
  Future<String?> read() async => _encoded;

  @override
  Future<void> clear() async => _encoded = null;
}

/// String bag with the SharedPreferences methods this package uses.
///
/// This is a stub — it does not import the `shared_preferences` plugin.
class SharedPrefsStub {
  /// Creates a stub, optionally seeded with existing key/value pairs.
  SharedPrefsStub([Map<String, Object>? seed])
      : _data = Map<String, Object>.from(seed ?? const {});

  final Map<String, Object> _data;

  /// Returns the string at [key], or `null`.
  String? getString(String key) {
    final value = _data[key];
    return value is String ? value : null;
  }

  /// Writes [value] at [key].
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  /// Removes [key].
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }
}

/// [ShiftStorage] backed by a [SharedPrefsStub].
class SharedPrefsShiftStorage implements ShiftStorage {
  /// Preference key used when none is supplied.
  static const String defaultKey = 'oe_shift.state';

  /// Creates a store. Pass [prefs] to inject a pre-loaded stub (tests).
  SharedPrefsShiftStorage({
    SharedPrefsStub? prefs,
    String key = defaultKey,
  })  : _prefs = prefs ?? SharedPrefsStub(),
        _key = key;

  final SharedPrefsStub _prefs;
  final String _key;

  @override
  Future<void> write(String encoded) async {
    await _prefs.setString(_key, encoded);
  }

  @override
  Future<String?> read() async => _prefs.getString(_key);

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
