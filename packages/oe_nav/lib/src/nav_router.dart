import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'nav_destinations.dart';
import 'nav_shell.dart';
import 'nav_tab.dart';

/// Composable tab [StatefulShellRoute] for a host-owned [GoRouter].
///
/// The host keeps splash, login, and nested order-detail routes. Preview
/// apps that only need the five tabs can use [createOeNavRouter] instead.
StatefulShellRoute oeNavStatefulShellRoute({
  OeNavDestinations destinations = const OeNavDestinations(),
}) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return OeNavShell(
        selectedTab: OeNavTab.values[navigationShell.currentIndex],
        onTabSelected: (tab) => navigationShell.goBranch(tab.index),
        child: navigationShell,
      );
    },
    branches: [
      for (final tab in OeNavTab.values)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: tab.location,
              builder: (context, state) => destinations.pageFor(tab, context),
            ),
          ],
        ),
    ],
  );
}

/// Preview / test [GoRouter] with `/` → `/orders` and the five tab branches.
///
/// Host apps should compose [oeNavStatefulShellRoute] into their own router
/// so splash, login, and detail routes stay outside this package.
GoRouter createOeNavRouter({
  OeNavDestinations destinations = const OeNavDestinations(),
  String? initialLocation,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation ?? OeNavTab.orders.location,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => OeNavTab.orders.location,
      ),
      oeNavStatefulShellRoute(destinations: destinations),
    ],
  );
}
