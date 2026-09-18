import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/delivery.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/dummy_delivery_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required DummyDeliveryApi api,
    required SharedPreferences prefs,
  })  : _api = api,
        _prefs = prefs;

  final DummyDeliveryApi _api;
  final SharedPreferences _prefs;

  static const _tokenKey = 'rider_token';
  static const _riderIdKey = 'rider_id';
  static const _nameKey = 'rider_name';

  @override
  Future<RiderSession?> restoreSession() async {
    final token = _prefs.getString(_tokenKey);
    final riderId = _prefs.getString(_riderIdKey);
    final name = _prefs.getString(_nameKey);
    if (token == null || riderId == null || name == null) return null;
    return RiderSession(riderId: riderId, displayName: name, token: token);
  }

  @override
  Future<RiderSession> login({
    required String phone,
    required String pin,
  }) async {
    final session = await _api.login(phone: phone, pin: pin);
    await _prefs.setString(_tokenKey, session.token);
    await _prefs.setString(_riderIdKey, session.riderId);
    await _prefs.setString(_nameKey, session.displayName);
    return session;
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_riderIdKey);
    await _prefs.remove(_nameKey);
  }
}
