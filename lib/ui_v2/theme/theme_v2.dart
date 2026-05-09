import 'package:flutter/material.dart';

class ThemeV2 {}

class V4ThemeIntent {}

class BrandTheme extends ThemeExtension<BrandTheme> {
  const BrandTheme({
    this.radius = 0.0,
    this.elevationLow = 0.0,
    this.elevationMed = 0.0,
    this.spacingSmall = 0.0,
    this.spacingMedium = 0.0,
    this.spacingLarge = 0.0,
    this.primaryBrand = _kDefaultColor,
    this.accentSuccess = _kDefaultColor,
    this.textPrimary = _kDefaultColor,
    this.textSecondary = _kDefaultColor,
  });

  static const Color _kDefaultColor = Color(0xFF000000);

  final double radius;
  final double elevationLow;
  final double elevationMed;
  final double spacingSmall;
  final double spacingMedium;
  final double spacingLarge;
  final Color primaryBrand;
  final Color accentSuccess;
  final Color textPrimary;
  final Color textSecondary;

  @override
  BrandTheme copyWith({
    double? radius,
    double? elevationLow,
    double? elevationMed,
    double? spacingSmall,
    double? spacingMedium,
    double? spacingLarge,
    Color? primaryBrand,
    Color? accentSuccess,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return BrandTheme(
      radius: radius ?? this.radius,
      elevationLow: elevationLow ?? this.elevationLow,
      elevationMed: elevationMed ?? this.elevationMed,
      spacingSmall: spacingSmall ?? this.spacingSmall,
      spacingMedium: spacingMedium ?? this.spacingMedium,
      spacingLarge: spacingLarge ?? this.spacingLarge,
      primaryBrand: primaryBrand ?? this.primaryBrand,
      accentSuccess: accentSuccess ?? this.accentSuccess,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  BrandTheme lerp(ThemeExtension<BrandTheme>? other, double t) {
    if (other is! BrandTheme) return this;
    return t < 0.5 ? this : other;
  }
}
