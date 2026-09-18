import 'package:flutter/material.dart';

/// Bottom-nav destinations for the delivery-partner shell.
enum OeNavTab {
  /// Assigned out-for-delivery list (host injects the real screen).
  orders,

  /// Map / stop navigation stub (host injects the real screen).
  map,

  /// Rider earnings summary (host injects the real screen).
  earnings,

  /// Completed delivery history (host injects the real screen).
  history,

  /// Rider profile placeholder.
  profile;

  /// Visible [NavigationBar] label.
  String get label => switch (this) {
        orders => 'Orders',
        map => 'Map',
        earnings => 'Earnings',
        history => 'History',
        profile => 'Profile',
      };

  /// Outline icon used when the tab is not selected.
  IconData get icon => switch (this) {
        orders => Icons.local_shipping_outlined,
        map => Icons.map_outlined,
        earnings => Icons.payments_outlined,
        history => Icons.receipt_long_outlined,
        profile => Icons.person_outline,
      };

  /// Filled icon used when the tab is selected.
  IconData get selectedIcon => switch (this) {
        orders => Icons.local_shipping,
        map => Icons.map,
        earnings => Icons.payments,
        history => Icons.receipt_long,
        profile => Icons.person,
      };

  /// go_router location for this branch (`/orders`, `/map`, …).
  String get location => '/$name';
}
