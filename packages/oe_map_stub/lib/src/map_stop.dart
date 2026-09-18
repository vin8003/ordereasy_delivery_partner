import 'package:flutter/foundation.dart';

/// A delivery-stop destination used to build a maps URL.
@immutable
class MapStop {
  /// Creates a stop at [lat], [lng] with a human-readable [label].
  const MapStop({
    required this.lat,
    required this.lng,
    required this.label,
  });

  /// Latitude in decimal degrees (WGS 84).
  final double lat;

  /// Longitude in decimal degrees (WGS 84).
  final double lng;

  /// Display name for the stop (drop-off, hub, etc.).
  final String label;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MapStop &&
            lat == other.lat &&
            lng == other.lng &&
            label == other.label;
  }

  @override
  int get hashCode => Object.hash(lat, lng, label);

  @override
  String toString() => 'MapStop(lat: $lat, lng: $lng, label: $label)';
}
