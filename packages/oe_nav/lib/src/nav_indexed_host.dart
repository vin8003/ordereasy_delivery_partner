import 'package:flutter/material.dart';

import 'nav_destinations.dart';
import 'nav_shell.dart';
import 'nav_tab.dart';

/// Navigator / [IndexedStack] wiring when the host is not using go_router.
class OeNavIndexedHost extends StatefulWidget {
  /// Creates an [IndexedStack] shell starting at [initialTab].
  const OeNavIndexedHost({
    super.key,
    this.destinations = const OeNavDestinations(),
    this.initialTab = OeNavTab.orders,
  });

  /// Optional imported feature stubs.
  final OeNavDestinations destinations;

  /// First visible tab.
  final OeNavTab initialTab;

  @override
  State<OeNavIndexedHost> createState() => _OeNavIndexedHostState();
}

class _OeNavIndexedHostState extends State<OeNavIndexedHost> {
  late OeNavTab _tab = widget.initialTab;

  @override
  void didUpdateWidget(covariant OeNavIndexedHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab &&
        widget.initialTab != _tab) {
      _tab = widget.initialTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OeNavShell(
      selectedTab: _tab,
      onTabSelected: (tab) => setState(() => _tab = tab),
      child: IndexedStack(
        index: _tab.index,
        children: [
          for (final tab in OeNavTab.values)
            widget.destinations.pageFor(tab, context),
        ],
      ),
    );
  }
}
