import 'package:flutter/foundation.dart';

import 'nav_tab.dart';

/// Widget keys used by the shell and by widget tests.
abstract final class OeNavKeys {
  /// [OeNavShell] scaffold.
  static const Key shell = Key('oe-nav-shell');

  /// Material 3 [NavigationBar].
  static const Key bar = Key('oe-nav-bar');

  /// Key for the visible page of [tab].
  static Key page(OeNavTab tab) => Key('oe-nav-page-${tab.name}');

  /// Key for the [NavigationDestination] of [tab].
  static Key destination(OeNavTab tab) => Key('oe-nav-dest-${tab.name}');
}
