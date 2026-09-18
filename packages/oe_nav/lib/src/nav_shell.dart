import 'package:flutter/material.dart';

import 'nav_keys.dart';
import 'nav_tab.dart';

/// Material 3 [NavigationBar] shell. The [child] is the active tab body.
class OeNavShell extends StatelessWidget {
  /// Creates the bottom-nav chrome around [child].
  const OeNavShell({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.child,
  });

  /// Currently selected destination.
  final OeNavTab selectedTab;

  /// Invoked when the rider taps a destination.
  final ValueChanged<OeNavTab> onTabSelected;

  /// Active branch content (router shell or [IndexedStack]).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: OeNavKeys.shell,
      body: child,
      bottomNavigationBar: NavigationBar(
        key: OeNavKeys.bar,
        selectedIndex: selectedTab.index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          onTabSelected(OeNavTab.values[index]);
        },
        destinations: [
          for (final tab in OeNavTab.values)
            NavigationDestination(
              key: OeNavKeys.destination(tab),
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
