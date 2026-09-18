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

## Host dependency

```yaml
dependencies:
  oe_nav:
    path: packages/oe_nav
```

## Public API

The **host owns `GoRouter`**. Compose the tab shell next to splash, login,
and order-detail routes:

```dart
import 'package:go_router/go_router.dart';
import 'package:oe_nav/oe_nav.dart';

final router = GoRouter(
  initialLocation: '/orders',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginStub()),
    oeNavStatefulShellRoute(
      destinations: OeNavDestinations(
        orders: (context) => const OrdersImportStub(),
        map: (context) => const MapImportStub(),
      ),
    ),
  ],
);
```

Navigator / `IndexedStack` without go_router:

```dart
const OeNavIndexedHost();
```

`createOeNavRouter` and `OeNavApp` are preview/test helpers only.
