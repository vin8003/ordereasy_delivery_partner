import 'auth_config.dart';
import 'auth_user.dart';

/// Phone + OTP authentication for a delivery partner.
abstract class AuthRepository {
  /// Active configuration (includes [AuthConfig.baseUrl]).
  AuthConfig get config;

  /// Starts a dummy (or real) OTP challenge for [phone].
  Future<void> requestOtp(String phone);

  /// Completes login with [phone] and [otp].
  ///
  /// Throws [InvalidOtpException] when [otp] is rejected.
  Future<AuthUser> login({required String phone, required String otp});

  /// Clears the stored token and local session.
  Future<void> logout();

  /// The signed-in user, or `null` when no token is stored.
  Future<AuthUser?> currentUser();

  /// Whether an access token is present.
  Future<bool> isLoggedIn();
}
