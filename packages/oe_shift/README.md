# oe_shift

Isolated dummy **online/offline** and **shift** toggle for the OrderEasy
delivery-partner app.

Other packages can depend on this library without touching the app-root
scaffold or any other `oe_*` package.

## Dummy only

- In-process availability + shift clock. No HTTP.
- Persistence is [InMemoryShiftStorage] (default) or a
  [SharedPrefsShiftStorage] stub — not the `shared_preferences` plugin.
- `ShiftConfig.baseUrl` defaults to `http://127.0.0.1:8080`.
- Live `*.ordereasy.win` hosts are rejected.

## Public API

```dart
import 'package:oe_shift/oe_shift.dart';

final shift = DummyShiftRepository(
  config: ShiftConfig(), // baseUrl: http://127.0.0.1:8080
  storage: InMemoryShiftStorage(),
);

await shift.startShift(); // on-shift, still offline
await shift.goOnline(); // available for assignments
await shift.goOffline(); // pause; shift stays open
await shift.toggleOnline();
await shift.toggleShift();
```

Use `SharedPrefsShiftStorage(prefs: SharedPrefsStub())` when the host wants
a SharedPreferences-shaped bag without a plugin.

## Rules

- Going online starts a shift if none is open.
- Going offline does not end the shift.
- Ending a shift forces the rider offline.
- `RiderShift` stores timestamps in UTC and treats online as on-shift.
