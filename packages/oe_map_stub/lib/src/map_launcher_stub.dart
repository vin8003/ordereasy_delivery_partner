import 'map_stop.dart';
import 'map_url_format.dart';

/// Builds a maps URL for a [MapStop] without SDKs, keys, or network calls.
class MapLauncherStub {
  /// Creates a stub launcher.
  ///
  /// [format] defaults to [MapUrlFormat.geo] so the host can hand the string
  /// to a platform maps app. [osmZoom] is used only for OpenStreetMap URLs.
  const MapLauncherStub({
    this.format = MapUrlFormat.geo,
    this.osmZoom = 17,
  });

  /// Which URL shape [urlFor] returns.
  final MapUrlFormat format;

  /// OpenStreetMap hash zoom, expected in `1..19`.
  final int osmZoom;

  /// Returns a maps URL for [stop] using [format].
  String urlFor(MapStop stop) {
    return switch (format) {
      MapUrlFormat.geo => geoUrl(stop),
      MapUrlFormat.openStreetMap => openStreetMapUrl(stop),
    };
  }

  /// `geo:lat,lng?q=lat,lng(label)` with a percent-encoded label.
  String geoUrl(MapStop stop) {
    final lat = _formatCoord(stop.lat, 'lat');
    final lng = _formatCoord(stop.lng, 'lng');
    final encodedLabel = Uri.encodeComponent(stop.label);
    return 'geo:$lat,$lng?q=$lat,$lng($encodedLabel)';
  }

  /// Marker URL on `www.openstreetmap.org` (no keys, no network from here).
  String openStreetMapUrl(MapStop stop) {
    if (osmZoom < 1 || osmZoom > 19) {
      throw ArgumentError.value(osmZoom, 'osmZoom', 'must be in [1, 19]');
    }
    final lat = _formatCoord(stop.lat, 'lat');
    final lng = _formatCoord(stop.lng, 'lng');
    return 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=$osmZoom/$lat/$lng';
  }

  String _formatCoord(double value, String name) {
    if (!_isValidCoordinate(value, name: name)) {
      throw ArgumentError.value(
        value,
        name,
        name == 'lat'
            ? 'must be finite and within [-90, 90]'
            : 'must be finite and within [-180, 180]',
      );
    }
    return value.toStringAsFixed(6);
  }

  bool _isValidCoordinate(double value, {required String name}) {
    if (!value.isFinite) {
      return false;
    }
    if (name == 'lat') {
      return value >= -90 && value <= 90;
    }
    return value >= -180 && value <= 180;
  }
}
