# oe_history

Isolated dummy **completed delivery history** list for the OrderEasy
delivery-partner app.

This package is self-contained. It does **not** rewrite or depend on the
app-root Flutter scaffold (or any other `oe_*` package).

## Path dependency

Wire it from the host app when the scaffold is ready. Do **not** add this
path dependency from this PR — leave the app shell untouched:

```yaml
dependencies:
  oe_history:
    path: packages/oe_history
```

```dart
import 'package:oe_history/oe_history.dart';

final history = DummyHistoryRepository(); // in-memory fixture JSON

// Host route, when you add one:
HistoryListScreen(repository: history);
```

## Dummy only

- Models + `HistoryRepository` backed by in-memory / fixture JSON.
- No HTTP. `HistoryConfig.baseUrl` defaults to `http://127.0.0.1:8080`.
- Live OrderEasy production hosts and other `*.win` hosts are rejected.

## Public API

| Export | Role |
| --- | --- |
| `CompletedDelivery` | order id, address, status, completed time, earnings stub |
| `HistoryStatus` | `delivered` / `delivery_failed` |
| `EarningsStub` | per-order earnings placeholder (`₹85.50`) |
| `groupCompletedDeliveries` | UTC date groups, newest first |
| `DummyHistoryRepository` | fixture JSON or `DummyHistoryRepository.empty()` |
| `HistoryListScreen` | date-grouped list (order id, address snippet, status, earnings) |

```bash
cd packages/oe_history
flutter pub get
flutter test
```
