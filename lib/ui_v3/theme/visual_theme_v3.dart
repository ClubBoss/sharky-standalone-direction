import 'package:flutter/material.dart';

import '../../services/personalization_context.dart';
import 'visual_micro_modifiers.dart';

/// VisualThemeV3 centralizes the visual language for the V3 UI layer.
class PersonalizationPalette {
  const PersonalizationPalette({
    this.intensityScale,
    this.glowScale,
    this.accentMode,
  });

  final double? intensityScale;
  final double? glowScale;
  final String? accentMode;
}

class VisualThemeV3 {
  VisualThemeV3._();

  static PersonalizationPalette deriveFrom(PersonalizationContext ctx) =>
      const PersonalizationPalette(
        intensityScale: null,
        glowScale: null,
        accentMode: null,
      );

  static VisualMicroModifiers getModifiers(PersonalizationPalette palette) {
    return VisualMicroModifiers(palette);
  }

  /// Toggle for light/dark brand skins (no functional changes elsewhere).
  static const bool kUseDarkSkin = false;

  /// Brand palette (Z6): primary, success, danger, warning.
  /// Reference hexes per spec.
  static const Color primary = Color(0xFF1565C0); // #1565C0
  static const Color success = Color(0xFF43A047); // #43A047
  static const Color danger = Color(0xFFE53935); // #E53935
  static const Color warning = Color(0xFFFB8C00); // #FB8C00

  /// Brand color extensions (V2)
  static const Color secondaryAccent = Color(0xFF00ACC1); // cyan 700
  static const Color neutralGrey = Color(0xFF90A4AE); // blueGrey 300
  static Color get backgroundHighlight =>
      kUseDarkSkin ? const Color(0xFF17212B) : const Color(0xFFEEF3F9);

  /// Supporting neutrals and surfaces derived per skin.
  static const Color surfaceLight = Color(0xFFF4F6FB);
  static const Color surfaceDark = Color(0xFF0E141A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16202A);
  static const Color textPrimaryLight = Color(0xFF0F2436);
  static const Color textPrimaryDark = Color(0xFFE2E7EC);
  static const Color textSecondaryLight = Color(0xFF455A64);
  static const Color textSecondaryDark = Color(0xFFB7C1C8);

  /// Backwards compatibility tokens (kept to avoid breakage in V2 UI):
  static const Color secondary = warning; // Highlight/accent
  static const Color surface = surfaceLight; // default is light skin
  static const Color card = cardLight;
  static const Color accent = Color(0xFF4DD0E1); // teal accent (legacy)
  static const Color primaryText = textPrimaryLight;
  static const Color secondaryText = textSecondaryLight;
  static const Color neutral = textPrimaryLight;

  /// Secondary accent for highlights and interactive elements
  static const Color accentSecondary = Color(0xFFFF6F00);

  /// Border radius
  static const double cardRadius = 16.0;

  /// Elevation tokens (soft shadows)
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  static const Duration motionFast = Duration(milliseconds: 111);
  static const Duration motionMedium = Duration(milliseconds: 186);
  static const Duration motionSlow = Duration(milliseconds: 260);

  /// UX motion tokens (Z5)
  static const Duration speedFast = Duration(milliseconds: 111);
  static const Duration speedNormal = Duration(milliseconds: 186);
  static const Duration speedSlow = Duration(milliseconds: 260);

  /// Spacing tokens (Z5)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingSM = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  /// Glow tokens (Φ1) for visual engagement effects
  static Color get glowColorSuccess => success.withValues(alpha: 0.4);
  static Color get glowColorError => danger.withValues(alpha: 0.4);
  static const double glowIntensity = 8.0; // blur radius for glow effects

  /// Shimmer gradient for chip movement animations
  static LinearGradient get shimmerGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.transparent,
      warning.withValues(alpha: 0.3),
      Colors.transparent,
    ],
    stops: const [0.0, 0.5, 1.0],
  );

  /// Background gradient (changes with skin) and table gradient (legacy alias).
  static LinearGradient get backgroundGradient => kUseDarkSkin
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0F14), Color(0xFF14212E)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F9FC), Color(0xFFE8EEF6)],
        );

  static LinearGradient get tableGradient => backgroundGradient;

  /// Marketing accent gradients (V2)
  static const LinearGradient _marketingAccentGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondaryAccent],
  );

  static const LinearGradient _marketingAccentGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), secondaryAccent],
  );

  static LinearGradient get marketingAccentGradient => kUseDarkSkin
      ? _marketingAccentGradientDark
      : _marketingAccentGradientLight;

  /// Brand background gradient variant for product/marketing screens
  static LinearGradient get brandBackgroundGradient => kUseDarkSkin
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E1620), Color(0xFF1A2A3A)],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundHighlight, const Color(0xFFE7EEF8)],
        );

  /// Shadow tokens
  static const BoxShadow shadowLight = BoxShadow(
    color: Color(0x14000000), // ~8% black
    blurRadius: 6,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x26000000), // ~15% black
    blurRadius: 12,
    offset: Offset(0, 6),
  );

  static const BoxShadow shadowHigh = BoxShadow(
    color: Color(0x33000000), // ~20% black
    blurRadius: 18,
    offset: Offset(0, 8),
  );

  static ThemeData get theme => _cachedTheme ??= _createTheme();
  static ThemeData? _cachedTheme;

  static ThemeData _createTheme() {
    final base = kUseDarkSkin ? ThemeData.dark() : ThemeData.light();

    final scheme = base.colorScheme;
    final surfaceColor = kUseDarkSkin ? surfaceDark : surfaceLight;
    final cardColor = kUseDarkSkin ? cardDark : cardLight;
    final onPrimary = Colors.white;
    final onSecondary = kUseDarkSkin ? Colors.white : Colors.black;
    final onSurface = kUseDarkSkin ? textPrimaryDark : neutral;

    final colorScheme = scheme.copyWith(
      primary: primary,
      secondary: warning,
      surface: surfaceColor,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onSurface: onSurface,
      error: danger,
    );

    // Standardized typography tokens (h1, h2, body, caption, button)
    final textThemeBase = base.textTheme.apply(
      bodyColor: onSurface.withValues(alpha: 0.9),
      displayColor: onSurface,
      fontFamily: 'Roboto',
    );
    final textTheme = textThemeBase.copyWith(
      displaySmall: textThemeBase.displaySmall?.copyWith(
        // h1
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      headlineSmall: textThemeBase.headlineSmall?.copyWith(
        // h2
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      bodyMedium: textThemeBase.bodyMedium?.copyWith(
        // body
        fontSize: 14,
        height: 1.35,
      ),
      bodySmall: textThemeBase.bodySmall?.copyWith(
        // caption
        fontSize: 12,
        color: onSurface.withValues(alpha: 0.75),
      ),
      labelLarge: textThemeBase.labelLarge?.copyWith(
        // button
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceColor,
      cardColor: cardColor,
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 1,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warning,
          elevation: elevationMedium,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(88, 48), // ≥ 48dp hit area
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          minimumSize: const Size(88, 48),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: elevationLow,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerColor: onSurface.withValues(alpha: 0.08),
      splashColor: accent.withValues(alpha: 0.15),
      highlightColor: accent.withValues(alpha: 0.08),
    );
  }

  /// Brand Identity (V2): central place to hook identity without impacting logic.
  static const BrandIdentity brand = BrandIdentity(
    logoPath:
        '', // Provide assets/brand/logo.(png|svg) and set hasLogo=true to enable
    mascotSet: <String>[],
    fontScale: 1.0,
    hasLogo: false,
  );
}

/// Immutable brand identity struct.
class BrandIdentity {
  const BrandIdentity({
    required this.logoPath,
    required this.mascotSet,
    required this.fontScale,
    this.hasLogo = false,
  });

  final String logoPath; // e.g., assets/brand/logo.png (ASCII-safe path)
  final List<String> mascotSet; // e.g., assets/brand/mascot/*.png|svg
  final double fontScale; // 1.0 = default
  final bool hasLogo; // gate to avoid runtime asset lookups
}
