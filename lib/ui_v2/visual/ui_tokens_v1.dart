import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

/// Non-table UI tokens anchored to the visual system inventory.
/// See docs/visual_system_inventory_v1.md#colors for palette usage.
/// See docs/visual_system_inventory_v1.md#spacing-scale for spacing scales.
/// See docs/visual_system_inventory_v1.md#corners--elevation for radii.
/// See docs/visual_system_inventory_v1.md#typography for text styles.
abstract class UiTokensV1 {
  UiTokensV1._();
}

class UiColorsV1 {
  UiColorsV1._();

  static const Color background = AppColors.neutralBg;
  static const Color lightBackground = AppColors.lightBackground;
  static const Color surface = AppColors.surface;
  static const Color surfaceVariant = AppColors.surfaceVariant;
  static const Color outlineSoft = AppColors.outlineSoft;
  static const Color primaryBrand = AppColors.primaryBrand;
  static const Color accentSuccess = AppColors.accentSuccess;
  static const Color accentWarning = AppColors.accentWarning;
  static const Color textPrimary = AppColors.textPrimaryDark;
  static const Color textSecondary = AppColors.textSecondaryDark;
}

class UiSpacingV1 {
  UiSpacingV1._();

  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
}

class UiRadiiV1 {
  UiRadiiV1._();

  static const double card = 12;
  static const double pill = 999;
}

class UiTextStylesV1 {
  UiTextStylesV1._();

  static const TextStyle headline = AppTypography.h1;
  static const TextStyle subtitle = AppTypography.h3;
  static const TextStyle body = AppTypography.body;
  static const TextStyle label = AppTypography.label;
  static const TextStyle caption = AppTypography.caption;
}
