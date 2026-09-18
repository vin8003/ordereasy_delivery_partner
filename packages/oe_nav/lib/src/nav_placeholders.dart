import 'package:flutter/material.dart';

import 'nav_keys.dart';
import 'nav_tab.dart';

/// Theme-aware stub page. Feature screens are not implemented in this package.
class OeNavPlaceholderPage extends StatelessWidget {
  /// Creates a dummy page for [tab].
  const OeNavPlaceholderPage({super.key, required this.tab});

  /// Which tab this placeholder represents.
  final OeNavTab tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      key: OeNavKeys.page(tab),
      color: colorScheme.surface,
      child: Center(
        child: Text(
          '${tab.label} placeholder',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
