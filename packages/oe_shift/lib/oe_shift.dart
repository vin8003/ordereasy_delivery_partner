/// Dummy rider online/offline and shift toggle.
///
/// Depend on this library from other packages. The default
/// [ShiftConfig.baseUrl] is `http://127.0.0.1:8080` — never a live OrderEasy
/// host. Persistence is in-process memory or a SharedPreferences-shaped stub.
library;

export 'src/dummy_shift_repository.dart';
export 'src/rider_shift.dart';
export 'src/shift_config.dart';
export 'src/shift_repository.dart';
export 'src/shift_storage.dart';
