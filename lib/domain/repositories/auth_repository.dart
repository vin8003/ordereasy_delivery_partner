import '../models/delivery.dart';

abstract class AuthRepository {
  Future<RiderSession?> restoreSession();
  Future<RiderSession> login({
    required String phone,
    required String pin,
  });
  Future<void> logout();
}
