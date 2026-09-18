import 'package:flutter_test/flutter_test.dart';
import 'package:oe_auth/oe_auth.dart';

void main() {
  late InMemoryTokenStorage storage;
  late DummyAuthRepository repo;

  setUp(() {
    storage = InMemoryTokenStorage();
    repo = DummyAuthRepository(
      config: const AuthConfig(),
      tokenStorage: storage,
    );
  });

  test('default baseUrl is the local stub, not a live host', () {
    const config = AuthConfig();
    expect(config.baseUrl, 'http://127.0.0.1:8080');
    expect(config.baseUrl.contains('ordereasy.win'), isFalse);
    expect(repo.config.baseUrl, AuthConfig.defaultBaseUrl);
  });

  test('login succeeds with the dummy OTP and stores a token', () async {
    await repo.requestOtp('+919876543210');

    final user = await repo.login(phone: '+919876543210', otp: '123456');

    expect(user.id, 'dp_+919876543210');
    expect(user.phone, '+919876543210');
    expect(await repo.isLoggedIn(), isTrue);
    expect(await repo.currentUser(), user);
    expect(await storage.read(), 'dummy.dp_+919876543210');
  });

  test('login throws InvalidOtpException for a wrong OTP', () async {
    await repo.requestOtp('9876543210');

    await expectLater(
      repo.login(phone: '9876543210', otp: '000000'),
      throwsA(isA<InvalidOtpException>()),
    );

    expect(await repo.isLoggedIn(), isFalse);
    expect(await repo.currentUser(), isNull);
    expect(await storage.read(), isNull);
  });

  test('logout clears the dummy session', () async {
    await repo.login(phone: '9000000000', otp: AuthConfig.defaultDummyOtp);
    await repo.logout();

    expect(await repo.isLoggedIn(), isFalse);
    expect(await repo.currentUser(), isNull);
  });
}
