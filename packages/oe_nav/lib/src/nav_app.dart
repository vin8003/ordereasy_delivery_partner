import 'package:flutter/material.dart';

import 'nav_destinations.dart';
import 'nav_indexed_host.dart';
import 'nav_router.dart';
import 'nav_tab.dart';
import 'nav_theme.dart';

/// Tiny Material 3 host used by tests and dummy previews.
///
/// This is not a production app and does not call any network host.
class OeNavApp extends StatelessWidget {
  /// Creates a theme-aware shell around the nav stub.
  const OeNavApp({
    super.key,
    this.destinations = const OeNavDestinations(),
    this.brightness = Brightness.light,
    this.initialLocation,
    this.initialTab = OeNavTab.orders,
    this.useRouter = true,
  });

  /// Optional imported feature stubs.
  final OeNavDestinations destinations;

  /// Light or dark Material 3 scheme.
  final Brightness brightness;

  /// go_router start location. Defaults to [initialTab].
  final String? initialLocation;

  /// First tab for the [IndexedStack] host.
  final OeNavTab initialTab;

  /// When true, wires tabs with go_router; otherwise uses [OeNavIndexedHost].
  final bool useRouter;

  @override
  Widget build(BuildContext context) {
    final theme = oeNavTheme(brightness: brightness);
    if (!useRouter) {
      return MaterialApp(
        theme: theme,
        home: OeNavIndexedHost(
          destinations: destinations,
          initialTab: initialTab,
        ),
      );
    }

    return MaterialApp.router(
      theme: theme,
      routerConfig: createOeNavRouter(
        destinations: destinations,
        initialLocation: initialLocation ?? initialTab.location,
      ),
    );
  }
}
