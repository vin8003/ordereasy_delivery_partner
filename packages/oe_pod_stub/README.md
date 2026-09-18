# oe_pod_stub

Isolated dummy **proof-of-delivery photo stub** for the OrderEasy delivery
partner app.

Attach stub image + metadata to an out-for-delivery (OFD) order id held in
an in-memory store. The package does **not** open a camera, read files, or
perform HTTP.

## Dummy only

- Seeded OFD ids: `ofd-1001`, `ofd-1002`, `ofd-1003` (same ids the rider
  list uses). The store can be constructed empty or with a custom set.
- Default stub URI: `stub://photo/{orderId}`.
- Default `baseUrl` is `http://127.0.0.1:8080`. Live production hosts are
  rejected. `baseUrl` is recorded for a future client; this dummy never
  performs network I/O.

This package does **not** depend on `oe_orders`. The app can map an assigned
order id into `attach(orderId)` when packages are wired together.

## API

```dart
import 'package:oe_pod_stub/oe_pod_stub.dart';

final client = DummyPodClient(); // DummyPodStore of assigned OFD ids

final attached = await client.attach('ofd-1001');
// attached.photo.uri == 'stub://photo/ofd-1001'

await client.attach('ofd-missing'); // throws PodOrderNotFoundException
```

Custom metadata:

```dart
await client.attach(
  'ofd-1002',
  photo: const PodPhotoStub(
    uri: 'stub://photo/ofd-1002',
    mimeType: 'image/jpeg',
    fileName: 'doorstep.jpg',
    byteLength: 2048,
    note: 'Left with guard',
  ),
);
```
