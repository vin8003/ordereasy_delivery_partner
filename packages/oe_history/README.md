# oe_history

Isolated dummy package for a delivery partner's **completed** delivery
history (`delivered` / `delivery_failed`). This package does **not**
depend on `oe_orders` (assigned out-for-delivery).

## Models

`HistoryEntry` is a self-contained completed row (`id`, `status`,
`address`, `itemsSummary`, `completedAt`, optional `customerName` /
`failureReason`). Statuses are completed only — `out_for_delivery` is
rejected.

## Day filter stub

`DayFilter.all()` returns every fixture. `DayFilter.on(day)` keeps
entries whose `completedAt` falls on that UTC calendar day. The dummy
client records `?day=YYYY-MM-DD` on `historyUrl` but does not perform
HTTP.

```dart
final repo = HistoryRepository(); // baseUrl: http://127.0.0.1:8080
final today = await repo.listCompleted(
  filter: DayFilter.on(DateTime.utc(2026, 9, 18)),
);
```

## Hosts

Default `baseUrl` is `http://127.0.0.1:8080`. Hosts under
`*.ordereasy.win` (including `ordereasy.win`) are rejected.
