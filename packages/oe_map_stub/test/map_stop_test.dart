import 'package:flutter_test/flutter_test.dart';
import 'package:oe_map_stub/oe_map_stub.dart';

void main() {
  test('MapStop exposes lat, lng, and label', () {
    const stop = MapStop(lat: 12.97, lng: 77.59, label: 'Hub A');

    expect(stop.lat, 12.97);
    expect(stop.lng, 77.59);
    expect(stop.label, 'Hub A');
  });

  test('MapStop equality is by value', () {
    const a = MapStop(lat: 1, lng: 2, label: 'X');
    const b = MapStop(lat: 1, lng: 2, label: 'X');
    const c = MapStop(lat: 1, lng: 2, label: 'Y');

    expect(a, equals(b));
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(equals(c)));
  });
}
