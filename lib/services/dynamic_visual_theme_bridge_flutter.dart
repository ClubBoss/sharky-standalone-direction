import 'package:flutter/material.dart';

import 'dynamic_theme_spec.dart';

Future<ThemeData> applyDynamicThemeBridge(
  BuildContext context,
  DynamicThemeSpec spec,
  ThemeData? baseTheme,
) async {
  final base = baseTheme ?? Theme.of(context);
  final brightness = spec.brightness == 'light'
      ? Brightness.light
      : Brightness.dark;
  final accentColor = _hexToColor(spec.accentHex);
  final overlayAlpha = spec.overlayStrength.clamp(0.05, 1.0);

  final colorScheme = base.colorScheme.copyWith(
    brightness: brightness,
    primary: accentColor,
    secondary: accentColor.withValues(alpha: overlayAlpha),
    surfaceTint: accentColor.withValues(alpha: 0.2),
  );

  final textTheme = base.textTheme
      .apply(
        bodyColor: brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        displayColor: brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      )
      .copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      );

  final density = VisualDensity(
    horizontal: spec.densityDelta,
    vertical: spec.densityDelta,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    visualDensity: density,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20 * spec.spacingScale,
          vertical: 12 * spec.spacingScale,
        ),
      ),
    ),
    cardTheme: base.cardTheme.copyWith(
      color: brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.75)
          : Colors.white,
      elevation: 4 * spec.spacingScale,
      margin: EdgeInsets.all(12 * spec.spacingScale),
    ),
    textTheme: textTheme,
  );
}

Color _hexToColor(String hex) {
  final normalized = hex.replaceAll('#', '');
  final value = int.parse(normalized, radix: 16);
  return Color(0xFF000000 | value);
}
