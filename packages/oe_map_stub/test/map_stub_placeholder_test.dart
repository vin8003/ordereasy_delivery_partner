import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oe_map_stub/oe_map_stub.dart';

void main() {
  testWidgets('shows label, coordinates, and opens the stub URL', (
    tester,
  ) async {
    const stop = MapStop(lat: 12.9716, lng: 77.5946, label: 'Koramangala Hub');
    String? opened;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapStubPlaceholder(
            stop: stop,
            onOpenInMaps: (url) => opened = url,
          ),
        ),
      ),
    );

    expect(find.text('Koramangala Hub'), findsOneWidget);
    expect(find.text('12.9716, 77.5946'), findsOneWidget);
    expect(find.text('Open in maps'), findsOneWidget);

    await tester.tap(find.text('Open in maps'));
    expect(
      opened,
      const MapLauncherStub().urlFor(stop),
    );
  });
}
