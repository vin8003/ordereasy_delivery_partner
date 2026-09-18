# oe_accept

Isolated dummy client for a delivery partner to **accept** or **reject** an
assigned order. This package is self-contained: it does **not** depend on
`oe_orders`.

## Models

`OrderRef` is a minimal `{id}` handle so this package stays independent of
`oe_orders` models. When the app later wires `oe_orders`, map that order's
id into `OrderRef` (or pass the id string directly):

```dart
final ref = OrderRef(id: assignedOrder.id);
await client.acceptOrder(ref.id);
```

## API

```dart
final client = DummyAcceptClient(); // baseUrl: http://127.0.0.1:8080

final accepted = await client.acceptOrder(orderId);
final rejected = await client.rejectOrder(orderId, reason);
```

`AcceptResult.success` is `true` on dummy success and `false` on dummy
failure (empty id, empty reject reason, or an id in `failingOrderIds`).

## Hosts

Default `baseUrl` is `http://127.0.0.1:8080`. Hosts under `*.ordereasy.win`
(including `ordereasy.win`) are rejected. This dummy does not perform
network I/O; `baseUrl` is recorded for a future real client.
