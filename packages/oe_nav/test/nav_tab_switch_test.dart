import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oe_nav/oe_nav.dart';

void main() {
  test('tabs are Orders, Map, Earnings, History, Profile', () {
    expect(
      OeNavTab.values.map((tab) => tab.label).toList(),
      ['Orders', 'Map', 'Earnings', 'History', 'Profile'],
    );
    expect(
      OeNavTab.values.map((tab) => tab.location).toList(),
      ['/orders', '/map', '/earnings', '/history', '/profile'],
    );
  });

  testWidgets('go_router shell switches tabs to placeholder pages', (
    tester,
  ) async {
    await tester.pumpWidget(const OeNavApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(OeNavKeys.page(OeNavTab.orders)), findsOneWidget);
    expect(find.text('Orders placeholder'), findsOneWidget);

    await tester.tap(find.byKey(OeNavKeys.destination(OeNavTab.map)));
    await tester.pumpAndSettle();
    expect(find.byKey(OeNavKeys.page(OeNavTab.map)), findsOneWidget);
    expect(find.text('Map placeholder'), findsOneWidget);
    expect(find.text('Orders placeholder'), findsNothing);

    await tester.tap(find.byKey(OeNavKeys.destination(OeNavTab.earnings)));
    await tester.pumpAndSettle();
    expect(find.text('Earnings placeholder'), findsOneWidget);

    await tester.tap(find.byKey(OeNavKeys.destination(OeNavTab.history)));
    await tester.pumpAndSettle();
    expect(find.text('History placeholder'), findsOneWidget);

    await tester.tap(find.byKey(OeNavKeys.destination(OeNavTab.profile)));
    await tester.pumpAndSettle();
    expect(find.byKey(OeNavKeys.page(OeNavTab.profile)), findsOneWidget);
    expect(find.text('Profile placeholder'), findsOneWidget);
  });

  testWidgets('Navigator IndexedStack host switches tabs', (tester) async {
    await tester.pumpWidget(
      const OeNavApp(useRouter: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orders placeholder'), findsOneWidget);

    await tester.tap(find.byKey(OeNavKeys.destination(OeNavTab.profile)));
    await tester.pumpAndSettle();
    expect(find.text('Profile placeholder'), findsOneWidget);
    expect(find.text('Orders placeholder'), findsNothing);
  });

  testWidgets('host-supplied stub pages replace default placeholders', (
    tester,
  ) async {
    await tester.pumpWidget(
      OeNavApp(
        destinations: OeNavDestinations(
          orders: (_) => const Text('orders-import-stub'),
          map: (_) => const Text('map-import-stub'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('orders-import-stub'), findsOneWidget);
    expect(find.text('Orders placeholder'), findsNothing);

    await tester.tap(find.byKey(OeNavKeys.destination(OeNavTab.map)));
    await tester.pumpAndSettle();
    expect(find.text('map-import-stub'), findsOneWidget);
    expect(find.text('orders-import-stub'), findsNothing);
  });

  testWidgets('OeNavApp disposes its GoRouter without leaking exceptions', (
    tester,
  ) async {
    await tester.pumpWidget(const OeNavApp());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('five destinations fit a 360-wide phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const OeNavApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final tab in OeNavTab.values) {
      expect(find.byKey(OeNavKeys.destination(tab)), findsOneWidget);
    }
  });

  testWidgets('shell is Material 3 and follows the ambient theme', (
    tester,
  ) async {
    await tester.pumpWidget(const OeNavApp(brightness: Brightness.dark));
    await tester.pumpAndSettle();

    final navContext = tester.element(find.byType(NavigationBar));
    final theme = Theme.of(navContext);
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.brightness, Brightness.dark);

    final pageText = tester.widget<Text>(find.text('Orders placeholder'));
    expect(pageText.style?.color, theme.colorScheme.onSurface);
  });
}
