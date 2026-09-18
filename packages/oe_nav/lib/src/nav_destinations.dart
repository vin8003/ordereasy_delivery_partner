import 'package:flutter/widgets.dart';

import 'nav_placeholders.dart';
import 'nav_tab.dart';

/// Builds a tab body. Hosts import their own feature stubs here.
typedef OeNavPageBuilder = Widget Function(BuildContext context);

/// Optional page builders so this package does not own feature screens.
///
/// Leave a field null to keep [OeNavPlaceholderPage]. Do not add path
/// dependencies on `oe_orders` / `oe_map_stub` / `oe_earnings` / `oe_history`
/// from this package — the host wires those widgets in.
class OeNavDestinations {
  /// Creates injectable tab bodies.
  const OeNavDestinations({
    this.orders,
    this.map,
    this.earnings,
    this.history,
    this.profile,
  });

  /// Assigned OFD list stub.
  final OeNavPageBuilder? orders;

  /// Map / stop stub.
  final OeNavPageBuilder? map;

  /// Earnings summary stub.
  final OeNavPageBuilder? earnings;

  /// Completed-history stub.
  final OeNavPageBuilder? history;

  /// Profile placeholder (no feature package).
  final OeNavPageBuilder? profile;

  /// Resolves [tab] to a host stub or the built-in placeholder.
  Widget pageFor(OeNavTab tab, BuildContext context) {
    final builder = switch (tab) {
      OeNavTab.orders => orders,
      OeNavTab.map => map,
      OeNavTab.earnings => earnings,
      OeNavTab.history => history,
      OeNavTab.profile => profile,
    };
    return builder?.call(context) ?? OeNavPlaceholderPage(tab: tab);
  }
}
