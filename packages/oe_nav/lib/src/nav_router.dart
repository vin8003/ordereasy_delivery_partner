import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'nav_destinations.dart';
import 'nav_shell.dart';
import 'nav_tab.dart';

/// Builds a [GoRouter] whose branches are the five delivery-partner tabs.
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
      StatefulShellRoute.indexedStack(
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
                  builder: (context, state) =>
                      destinations.pageFor(tab, context),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}
