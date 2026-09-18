import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'nav_destinations.dart';
import 'nav_indexed_host.dart';
import 'nav_router.dart';
import 'nav_tab.dart';
import 'nav_theme.dart';

/// Tiny Material 3 host used by tests and dummy previews.
///
/// This is not a production app and does not call any network host.
/// Production apps should own [GoRouter] and compose
/// [oeNavStatefulShellRoute].
class OeNavApp extends StatefulWidget {
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
  State<OeNavApp> createState() => _OeNavAppState();
}

class _OeNavAppState extends State<OeNavApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _recreateRouter();
  }

  @override
  void didUpdateWidget(covariant OeNavApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final routerInputsChanged = oldWidget.destinations != widget.destinations ||
        oldWidget.initialLocation != widget.initialLocation ||
        oldWidget.initialTab != widget.initialTab ||
        oldWidget.useRouter != widget.useRouter;
    if (routerInputsChanged) {
      _recreateRouter();
    }
  }

  void _recreateRouter() {
    _router?.dispose();
    _router = widget.useRouter
        ? createOeNavRouter(
            destinations: widget.destinations,
            initialLocation:
                widget.initialLocation ?? widget.initialTab.location,
          )
        : null;
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = oeNavTheme(brightness: widget.brightness);
    final router = _router;
    if (router == null) {
      return MaterialApp(
        theme: theme,
        home: OeNavIndexedHost(
          destinations: widget.destinations,
          initialTab: widget.initialTab,
        ),
      );
    }

    return MaterialApp.router(
      theme: theme,
      routerConfig: router,
    );
  }
}
