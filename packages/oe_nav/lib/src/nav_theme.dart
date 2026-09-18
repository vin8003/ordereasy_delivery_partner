import 'package:flutter/material.dart';

/// Seed used by the delivery-partner scaffold (Material 3).
const Color kOeNavSeedColor = Color(0xFF0F6B4C);

/// Material 3 theme that follows [brightness].
ThemeData oeNavTheme({
  Brightness brightness = Brightness.light,
  Color seedColor = kOeNavSeedColor,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );
      }),
    ),
  );
}
