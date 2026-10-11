import 'package:flutter/material.dart';

/// Scoped V3 Editorial Tide tokens for the light Academy chrome
/// (Placement/Welcome/Home/Learn/Worlds presentation only).
///
/// This is intentionally separate from [Act0ShellTokensV1], which stays
/// dark/table-shared and must not be globally recolored. Only surfaces that
/// surround the protected Modern Table may consume these tokens.
class Act0AcademyDesignTokensV1 {
  const Act0AcademyDesignTokensV1._();

  static const Color pageSurface = Color(0xFFF7F5ED);
  static const Color cardSurface = Color(0xFFFFFEF9);
  static const Color ink = Color(0xFF182E32);
  static const Color inkMuted = Color(0xFF536560);
  static const Color focus = Color(0xFF126761);
  static const Color primaryAction = Color(0xFF17393A);
  static const Color onPrimaryAction = Color(0xFFFFFEF8);
  static const Color needsReviewFg = Color(0xFF7F4C13);
  static const Color needsReviewBg = Color(0xFFF2E5CD);
  static const Color correctFg = Color(0xFF226844);
  static const Color correctBg = Color(0xFFE1EEE2);
  static const Color rule = Color(0xFFCBD1C7);

  static const double gapXs = 8;
  static const double gapSm = 12;
  static const double gapMd = 16;
  static const double gapLg = 20;
  static const double gapXl = 24;

  static const double radiusCard = 6;
  static const double radiusCoachFrame = 12;

  // Display/section/lesson sizes follow the approved Editorial Tide rhythm.
  // Georgia is requested from the OS, never copied or fetched. Platforms
  // without it use their installed serif fallback; native fidelity is gated.
  static const String displayFont = 'Georgia';
  static const List<String> displayFallback = [
    'Times New Roman',
    'Noto Serif',
    'serif',
  ];
  static const TextStyle display = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    color: ink,
    fontSize: 38,
    height: 1.12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    color: ink,
    fontSize: 24,
    height: 1.14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle lessonHeading = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    color: ink,
    fontSize: 30,
    height: 1.16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Arial',
    fontFamilyFallback: ['Roboto', 'sans-serif'],
    color: ink,
    fontSize: 14,
    height: 1.6,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle supporting = TextStyle(
    fontFamily: 'Arial',
    fontFamilyFallback: ['Roboto', 'sans-serif'],
    color: inkMuted,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Arial',
    fontFamilyFallback: ['Roboto', 'sans-serif'],
    color: inkMuted,
    fontSize: 10,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static ButtonStyle primaryButtonStyle() => FilledButton.styleFrom(
    backgroundColor: primaryAction,
    foregroundColor: onPrimaryAction,
    disabledBackgroundColor: rule,
    disabledForegroundColor: inkMuted,
    minimumSize: const Size.fromHeight(52),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    textStyle: body.copyWith(fontWeight: FontWeight.w700, height: 1.25),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusCard),
    ),
  );

  static ButtonStyle secondaryButtonStyle() => OutlinedButton.styleFrom(
    foregroundColor: focus,
    minimumSize: const Size(48, 48),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    side: const BorderSide(color: rule),
    textStyle: body.copyWith(fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusCard),
    ),
  );

  static BoxDecoration cardDecoration({Color? borderColor, Color? color}) {
    return BoxDecoration(
      color: color ?? cardSurface,
      borderRadius: BorderRadius.circular(radiusCard),
      border: Border.all(color: borderColor ?? rule),
    );
  }
}
