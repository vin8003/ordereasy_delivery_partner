import 'auth_config.dart';
import 'auth_exception.dart';
import 'auth_repository.dart';
import 'auth_user.dart';
import 'token_storage.dart';

/// In-process auth that never performs network I/O.
///
/// [login] succeeds only when [otp] equals [AuthConfig.dummyOtp]
/// (`123456` by default). [AuthConfig.baseUrl] is retained for callers
/// but is not contacted.
class DummyAuthRepository implements AuthRepository {
  static const String _tokenPrefix = 'dummy.';

  final TokenStorage _storage;

  @override
  final AuthConfig config;

  /// Creates a dummy repository.
  ///
  /// Defaults to [InMemoryTokenStorage] so unit tests need no plugins.
  DummyAuthRepository({
    AuthConfig? config,
    TokenStorage? tokenStorage,
  })  : config = config ?? const AuthConfig(),
        _storage = tokenStorage ?? InMemoryTokenStorage();

  @override
  Future<void> requestOtp(String phone) async {
    _requirePhone(phone);
    // Stub: no SMS, no HTTP. The accepted code is [config.dummyOtp].
  }

  @override
  Future<AuthUser> login({
    required String phone,
    required String otp,
  }) async {
    final normalized = _requirePhone(phone);
    if (otp != config.dummyOtp) {
      throw const InvalidOtpException();
    }

    final user = AuthUser(id: 'dp_$normalized', phone: normalized);
    await _storage.write('$_tokenPrefix${user.id}');
    return user;
  }

  @override
  Future<void> logout() async {
    await _storage.clear();
  }

  @override
  Future<AuthUser?> currentUser() async {
    final token = await _storage.read();
    if (token == null || !token.startsWith(_tokenPrefix)) {
      return null;
    }
    final id = token.substring(_tokenPrefix.length);
    if (id.isEmpty || !id.startsWith('dp_')) {
      return null;
    }
    return AuthUser(id: id, phone: id.substring(3));
  }

  @override
  Future<bool> isLoggedIn() async => (await _storage.read()) != null;

  String _requirePhone(String phone) {
    final normalized = phone.trim();
    if (normalized.isEmpty) {
      throw const AuthException('Phone is required');
    }
    return normalized;
  }
}
