# oe_auth

Isolated dummy authentication for the OrderEasy delivery-partner app.

Other packages can depend on this library without touching the app-root scaffold.

## Dummy only

- Phone + OTP stubs. Accepted OTP is `123456` (`AuthConfig.dummyOtp`).
- No HTTP calls. `baseUrl` is configurable for a future client and defaults to `http://127.0.0.1:8080`.
- Do not point this package at live `*.ordereasy.win` hosts.

## Public API

```dart
import 'package:oe_auth/oe_auth.dart';

final auth = DummyAuthRepository(
  config: const AuthConfig(), // baseUrl: http://127.0.0.1:8080
  tokenStorage: InMemoryTokenStorage(),
);

await auth.requestOtp('+919876543210');
final user = await auth.login(phone: '+919876543210', otp: '123456');
```

Use `SharedPreferencesTokenStorage` when the session should survive process restarts.
