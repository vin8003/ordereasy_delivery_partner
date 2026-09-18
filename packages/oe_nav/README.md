# oe_nav

Isolated bottom navigation and route-shell stub for the OrderEasy
delivery-partner app.

Other packages can depend on this library without touching the app-root
scaffold. Feature screens are **not** implemented here — import stubs (or
keep the built-in placeholders).

## Dummy only

- Tabs: **Orders | Map | Earnings | History | Profile** (Profile is a
  placeholder).
- Default pages are theme-aware `OeNavPlaceholderPage` widgets.
- Hosts inject real/stub screens via `OeNavDestinations` — this package
  does not path-depend on `oe_auth`, `oe_orders`, or `oe_status`.
- No HTTP. Do not point this package at live `*.ordereasy.win` hosts.

## Public API

```dart
import 'package:oe_nav/oe_nav.dart';

// go_router shell (Material 3 NavigationBar)
final router = createOeNavRouter(
  destinations: OeNavDestinations(
    orders: (context) => const OrdersImportStub(),
    map: (context) => const MapImportStub(),
  ),
);

// Or Navigator / IndexedStack without go_router
const OeNavIndexedHost();
```

`OeNavApp` is a tiny Material 3 host for widget tests and local previews.
