/// Dummy delivery-partner authentication.
///
/// Depend on this library from other packages. The default [AuthConfig.baseUrl]
/// is `http://127.0.0.1:8080` — never a live OrderEasy host.
library;

export 'src/auth_config.dart';
export 'src/auth_exception.dart';
export 'src/auth_repository.dart';
export 'src/auth_user.dart';
export 'src/dummy_auth_repository.dart';
export 'src/token_storage.dart';
