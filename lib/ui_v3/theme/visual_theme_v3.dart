// Stub file — VisualThemeV3 was archived from ui_v3 but is still referenced
// by live ui_v2/table widgets. This provides the minimal constants needed so
// those files compile without changes.
import 'package:flutter/material.dart';

class VisualThemeV3 {
  VisualThemeV3._();

  // Brand palette
  static const Color primary = Color(0xFF1565C0);
  static const Color success = Color(0xFF43A047);
  static const Color danger = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);
  static const Color secondaryAccent = Color(0xFF00ACC1);
  static const Color neutralGrey = Color(0xFF90A4AE);

  // Surfaces
  static const Color surfaceLight = Color(0xFFF4F6FB);
  static const Color surfaceDark = Color(0xFF0E141A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16202A);
  static const Color textPrimaryLight = Color(0xFF0F2436);
  static const Color textPrimaryDark = Color(0xFFE2E7EC);
  static const Color textSecondaryLight = Color(0xFF455A64);
  static const Color textSecondaryDark = Color(0xFFB7C1C8);

  // Backwards-compat aliases
  static const Color card = cardLight;
  static const Color accent = Color(0xFF4DD0E1);
  static const Color accentSecondary = Color(0xFFFF6F00);
  static const Color primaryText = textPrimaryLight;
  static const Color secondaryText = textSecondaryLight;

  // Border radius
  static const double cardRadius = 16.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingSM = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Shadows
  static const BoxShadow shadowLight = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 6,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 12,
    offset: Offset(0, 6),
  );

  static const BoxShadow shadowHigh = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 18,
    offset: Offset(0, 8),
  );
}
