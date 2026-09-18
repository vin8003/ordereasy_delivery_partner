# oe_profile

Isolated rider profile/settings stub for the OrderEasy delivery-partner app.

Other packages can depend on this library without touching the app-root scaffold.

## Dummy only

- Profile fields: `name`, `phone`, optional `vehicle_number`, display-only `online` flag.
- `DummyProfileRepository` returns in-memory fixtures. No HTTP.
- `ProfileScreen` shows those fields and requires a `VoidCallback onLogout` stub. It does not clear auth.
- Do not point this package at live `*.ordereasy.win` hosts.
- This package never ships Windows (`*.win`) platform files.

## Public API

```dart
import 'package:oe_profile/oe_profile.dart';

final repo = DummyProfileRepository();
final profile = await repo.fetchProfile();

ProfileScreen(
  profile: profile,
  onLogout: () {
    // Host-owned. This package does not clear auth.
  },
);
```

`vehicle_number` is omitted from `toJson()` when null or empty.
