import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTypography for code under lib/** (v2 UI components).
abstract class AppTypography {
  // Heading: 20sp, w700 for stronger contrast.
  static const TextStyle h1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );

  // Body: 15sp, 1.4 line height for accessibility.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: AppColors.textSecondaryDark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondaryDark,
  );

  // New: label (14sp)
  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondaryDark,
    fontWeight: FontWeight.w500,
  );
}
