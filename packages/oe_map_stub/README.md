# oe_map_stub

Isolated navigation/map stub for the OrderEasy delivery-partner app.

This package **does not** embed Google Maps, Mapbox, or any other billed map
SDK. It never stores API keys and it never makes network calls. It only builds
a URL string (`geo:` or OpenStreetMap) that the host app can open with
`url_launcher` (or an equivalent).

## Usage

```dart
import 'package:oe_map_stub/oe_map_stub.dart';

const stop = MapStop(
  lat: 12.9716,
  lng: 77.5946,
  label: 'Koramangala Hub',
);

final geoUrl = const MapLauncherStub().urlFor(stop);
final osmUrl = const MapLauncherStub(
  format: MapUrlFormat.openStreetMap,
).urlFor(stop);
```

### Optional placeholder widget

```dart
MapStubPlaceholder(
  stop: stop,
  onOpenInMaps: (url) {
    // Host app launches [url]; this package does not.
  },
)
```

## URL formats

| Format | Example |
| --- | --- |
| `MapUrlFormat.geo` (default) | `geo:12.971600,77.594600?q=12.971600,77.594600(Koramangala%20Hub)` |
| `MapUrlFormat.openStreetMap` | `https://www.openstreetmap.org/?mlat=12.971600&mlon=77.594600#map=17/12.971600/77.594600` |
