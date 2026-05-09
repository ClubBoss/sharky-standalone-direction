import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

/// Immutable bundle describing the public brand surface for UI v3.
class BrandAssets {
  const BrandAssets({
    required this.logoPath,
    required this.mascotPath,
    required this.brandGradient,
    required this.tagline,
  });

  final String logoPath;
  final String mascotPath;
  final LinearGradient brandGradient;
  final String tagline;

  /// Loads the default brand assets baked into the application bundle.
  static BrandAssets loadFromAssets() {
    return const BrandAssets(
      logoPath: 'assets/brand/logo.svg',
      mascotPath: 'assets/brand/mascot.svg',
      brandGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [VisualThemeV3.textPrimaryLight, VisualThemeV3.primary],
      ),
      tagline: 'Train smarter. Play fearless.',
    );
  }
}

/// Convenience wrapper that couples [BrandAssets] with the active theme data.
class BrandTheme {
  const BrandTheme({required this.assets, required this.theme});

  final BrandAssets assets;
  final ThemeData theme;

  LinearGradient get gradient => assets.brandGradient;
}

/// Global accessor so UI elements can consume branding without recreating state.
BrandTheme get brandTheme => BrandTheme(
  assets: BrandAssets.loadFromAssets(),
  theme: VisualThemeV3.theme,
);
