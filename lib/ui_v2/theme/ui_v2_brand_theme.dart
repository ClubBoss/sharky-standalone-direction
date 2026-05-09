/// UI V2 Brand Theme Tokens
///
/// This file provides centralized brand theme tokens for UI V2 components.
/// For design handoff, see: lib/ui_v2/theme/design_tokens.md
///
/// All tokens are re-exported from the main theme system for consistency.
library;

export 'package:poker_analyzer/theme/theme_v2.dart' show BrandTheme;

/// Access BrandTheme in widgets:
/// ```dart
/// final brand = Theme.of(context).extension<BrandTheme>();
/// final spacing = brand?.spacingMedium ?? 16;
/// final radius = brand?.radius ?? 12;
/// final brandColor = brand?.primaryBrand ?? AppColors.primaryBrand;
/// ```
///
/// BrandTheme provides:
/// - brandName: String (default: "Poker Analyzer")
/// - radius: double (12px standard corner radius)
/// - elevationLow: double (1px subtle elevation)
/// - elevationMed: double (2px medium elevation)
/// - spacingSmall: double (8px tight spacing)
/// - spacingMedium: double (16px standard spacing)
/// - spacingLarge: double (24px wide spacing)
/// - primaryBrand: Color (#00B894 teal-green)
