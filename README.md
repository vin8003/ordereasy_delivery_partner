# OrderEasy Delivery Partner

Flutter mobile app for OrderEasy delivery riders: dummy login, assigned
`out_for_delivery` stops, navigate to a stop, mark `delivered` /
`delivery_failed` (optional note + photo stub), and sync status.

This app does **not** invent a parallel order engine. It only consumes a thin
rider delivery contract (dummy/local).

## Stack

- Flutter 3.x + Dart
- Targets: Android + iOS
- State: Riverpod
- Navigation: go_router
- Package layout: `app` / `features` / `data` / `domain`

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Optional dart-defines:

```bash
# Default (recommended): in-memory fixtures, no network
flutter run

# Hit a local dummy HTTP server instead of fixtures
flutter run \
  --dart-define=USE_LOCAL_FIXTURES=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

`API_BASE_URL` defaults to `http://127.0.0.1:8080`. Never point it at
`*.ordereasy.win` or other live production hosts.

### Dummy login

Any non-empty phone + PIN works in fixture mode (prefilled on the login screen).

## Screens

1. **Splash** — session restore
2. **Login (dummy)** — phone + PIN
3. **Home** — list of assigned `out_for_delivery` deliveries
4. **Detail** — stop info, navigate, mark delivered/failed
5. **Mark status** — optional note + photo stub, then sync

Optional fields (`landmark`, `notes`, `cod_amount`, `photo_url`,
`failure_reason`, etc.) are hidden when null/blank.

## Dummy API contract sketch

Base: `{API_BASE_URL}` (default `http://127.0.0.1:8080`)

### `POST /v1/rider/login`

```json
{ "phone": "9876543210", "pin": "1234" }
```

```json
{
  "rider_id": "rider-demo-1",
  "display_name": "Demo Rider",
  "token": "dummy-token-..."
}
```

### `GET /v1/rider/deliveries?status=out_for_delivery`

```json
{
  "deliveries": [
    {
      "id": "ofd-1001",
      "order_code": "OE-240918-001",
      "status": "out_for_delivery",
      "customer_name": "Anita Sharma",
      "customer_phone": "+91 98765 43210",
      "address_line": "12, Lake View Apartments, Sector 18",
      "landmark": "Near City Mall",
      "city": "Noida",
      "pincode": "201301",
      "lat": 28.5701,
      "lng": 77.3219,
      "item_summary": "2x Atta 5kg, 1x Milk 1L",
      "cod_amount": 420.0,
      "notes": "Call before ringing bell",
      "assigned_at": "2026-09-18T08:30:00Z",
      "photo_url": null,
      "failure_reason": null
    }
  ]
}
```

### `GET /v1/rider/deliveries/{id}`

Returns a single delivery object (same fields as above).

### `POST /v1/rider/deliveries/{id}/status`

```json
{
  "status": "delivered",
  "note": "Left with guard",
  "photo_stub": "stub://photo/ofd-1001"
}
```

Allowed `status` values from this app: `delivered`, `delivery_failed`.

Response: updated delivery object.

Fixture source used when `USE_LOCAL_FIXTURES=true`:
`assets/fixtures/deliveries.json`.

## Out of scope

Retailer POS, customer checkout, khata, UPI rails, inventory.adjust, pack SKU
engines, and status-timeline rewrites beyond displaying
`out_for_delivery` → `delivered` / `delivery_failed`.
