import 'package:flutter_test/flutter_test.dart';
import 'package:oe_map_stub/oe_map_stub.dart';

void main() {
  const stop = MapStop(
    lat: 12.9716,
    lng: 77.5946,
    label: 'Koramangala Hub',
  );

  group('MapLauncherStub.geo', () {
    const launcher = MapLauncherStub();

    test('defaults to the geo format', () {
      expect(launcher.format, MapUrlFormat.geo);
      expect(launcher.urlFor(stop), launcher.geoUrl(stop));
    });

    test('builds a geo URI with coordinates and an encoded label', () {
      expect(
        launcher.geoUrl(stop),
        'geo:12.971600,77.594600?q=12.971600,77.594600(Koramangala%20Hub)',
      );
    });

    test('urlFor returns a parseable geo URI', () {
      final url = launcher.urlFor(stop);
      final uri = Uri.parse(url);

      expect(url, startsWith('geo:'));
      expect(uri.scheme, 'geo');
      expect(uri.path, '12.971600,77.594600');
      expect(uri.queryParameters['q'], '12.971600,77.594600(Koramangala Hub)');
    });

    test('encodes reserved characters in the label', () {
      const messy = MapStop(
        lat: 19.0760,
        lng: 72.8777,
        label: 'Dock #4 & "North" (A/B)',
      );

      final url = launcher.geoUrl(messy);
      expect(url, startsWith('geo:19.076000,72.877700?q='));
      expect(url, isNot(contains(' & ')));
      expect(url, isNot(contains('"')));
      expect(
        Uri.parse(url).queryParameters['q'],
        '19.076000,72.877700(Dock #4 & "North" (A/B))',
      );
    });

    test('supports southern and western hemispheres', () {
      const sydney = MapStop(
        lat: -33.8688,
        lng: 151.2093,
        label: 'Circular Quay',
      );
      const sf = MapStop(
        lat: 37.7749,
        lng: -122.4194,
        label: 'Ferry Building',
      );

      expect(
        launcher.geoUrl(sydney),
        'geo:-33.868800,151.209300?q=-33.868800,151.209300(Circular%20Quay)',
      );
      expect(
        launcher.geoUrl(sf),
        'geo:37.774900,-122.419400?q=37.774900,-122.419400(Ferry%20Building)',
      );
    });
  });

  group('MapLauncherStub.openStreetMap', () {
    const launcher = MapLauncherStub(format: MapUrlFormat.openStreetMap);

    test('builds an OpenStreetMap HTTPS URL with marker and hash zoom', () {
      expect(
        launcher.urlFor(stop),
        'https://www.openstreetmap.org/?mlat=12.971600&mlon=77.594600#map=17/12.971600/77.594600',
      );
    });

    test('honors a custom zoom level', () {
      const zoomed = MapLauncherStub(
        format: MapUrlFormat.openStreetMap,
        osmZoom: 19,
      );

      expect(
        zoomed.openStreetMapUrl(stop),
        'https://www.openstreetmap.org/?mlat=12.971600&mlon=77.594600#map=19/12.971600/77.594600',
      );
    });

    test('urlFor returns a parseable OSM URI', () {
      final uri = Uri.parse(launcher.urlFor(stop));

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.openstreetmap.org');
      expect(uri.queryParameters['mlat'], '12.971600');
      expect(uri.queryParameters['mlon'], '77.594600');
      expect(uri.fragment, 'map=17/12.971600/77.594600');
    });
  });

  group('MapLauncherStub safety', () {
    test('never emits Google, Mapbox, API keys, or ordereasy.win hosts', () {
      const geo = MapLauncherStub();
      const osm = MapLauncherStub(format: MapUrlFormat.openStreetMap);
      const labeled = MapStop(
        lat: 28.6139,
        lng: 77.2090,
        label: 'CP Metro Hub',
      );

      for (final url in [geo.urlFor(labeled), osm.urlFor(labeled)]) {
        final lower = url.toLowerCase();
        expect(lower, isNot(contains('google')));
        expect(lower, isNot(contains('mapbox')));
        expect(lower, isNot(contains('googleapis')));
        expect(lower, isNot(contains('ordereasy.win')));
        expect(lower, isNot(contains('api_key')));
        expect(lower, isNot(contains('apikey')));
        expect(lower, isNot(contains('access_token')));
      }
    });
  });

  group('MapLauncherStub validation', () {
    const launcher = MapLauncherStub();

    test('rejects non-finite and out-of-range coordinates', () {
      const invalid = <MapStop>[
        MapStop(lat: 91, lng: 0, label: 'too north'),
        MapStop(lat: -90.0001, lng: 0, label: 'too south'),
        MapStop(lat: 0, lng: 181, label: 'too east'),
        MapStop(lat: 0, lng: -180.1, label: 'too west'),
        MapStop(lat: double.nan, lng: 0, label: 'nan lat'),
        MapStop(lat: 0, lng: double.infinity, label: 'inf lng'),
      ];

      for (final stop in invalid) {
        expect(
          () => launcher.urlFor(stop),
          throwsA(isA<ArgumentError>()),
          reason: 'expected ${stop.label} to be rejected',
        );
      }
    });

    test('rejects an OSM zoom outside 1..19', () {
      const low = MapLauncherStub(
        format: MapUrlFormat.openStreetMap,
        osmZoom: 0,
      );
      const high = MapLauncherStub(
        format: MapUrlFormat.openStreetMap,
        osmZoom: 20,
      );

      expect(() => low.urlFor(stop), throwsA(isA<ArgumentError>()));
      expect(() => high.urlFor(stop), throwsA(isA<ArgumentError>()));
    });

    test('accepts coordinate boundaries', () {
      const poles = MapStop(lat: 90, lng: -180, label: 'Edge');
      expect(launcher.geoUrl(poles), startsWith('geo:90.000000,-180.000000'));

      const other = MapStop(lat: -90, lng: 180, label: 'Edge');
      expect(launcher.geoUrl(other), startsWith('geo:-90.000000,180.000000'));
    });
  });
}
