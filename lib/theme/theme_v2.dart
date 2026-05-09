import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'app_colors.dart';
import 'app_typography.dart';
import 'brand_assets.dart';

/// Brand/spacing/theme tokens for UI v2 via ThemeExtension.
class BrandTheme extends ThemeExtension<BrandTheme> {
  final String brandName;
  final double radius;
  final double elevationLow;
  final double elevationMed;
  final double spacingSmall;
  final double spacingMedium;
  final double spacingLarge;
  final Color primaryBrand;
  final Color accentSuccess;
  final Color accentWarning;
  final Color textPrimary;
  final Color textSecondary;
  final String fontFamilyPrimary;
  final String fontFamilySecondary;
  final FontWeight fontWeightRegular;
  final FontWeight fontWeightMedium;
  final FontWeight fontWeightSemiBold;
  final double textScaleHeadline;
  final double textScaleBody;
  final double textScaleCaption;

  const BrandTheme({
    this.brandName = BrandAssets.brandName,
    this.radius = 12,
    this.elevationLow = 1,
    this.elevationMed = 2,
    this.spacingSmall = 8,
    this.spacingMedium = 16,
    this.spacingLarge = 24,
    this.primaryBrand = AppColors.primaryBrand,
    this.accentSuccess = AppColors.accentSuccess,
    this.accentWarning = AppColors.accentWarning,
    this.textPrimary = AppColors.textPrimaryDark,
    this.textSecondary = AppColors.textSecondaryDark,
    this.fontFamilyPrimary = 'Roboto',
    this.fontFamilySecondary = 'Roboto',
    this.fontWeightRegular = FontWeight.w400,
    this.fontWeightMedium = FontWeight.w500,
    this.fontWeightSemiBold = FontWeight.w600,
    this.textScaleHeadline = 1.0,
    this.textScaleBody = 1.0,
    this.textScaleCaption = 1.0,
  });

  @override
  BrandTheme copyWith({
    String? brandName,
    double? radius,
    double? elevationLow,
    double? elevationMed,
    double? spacingSmall,
    double? spacingMedium,
    double? spacingLarge,
    Color? primaryBrand,
    Color? accentSuccess,
    Color? accentWarning,
    Color? textPrimary,
    Color? textSecondary,
    String? fontFamilyPrimary,
    String? fontFamilySecondary,
    FontWeight? fontWeightRegular,
    FontWeight? fontWeightMedium,
    FontWeight? fontWeightSemiBold,
    double? textScaleHeadline,
    double? textScaleBody,
    double? textScaleCaption,
  }) => BrandTheme(
    brandName: brandName ?? this.brandName,
    radius: radius ?? this.radius,
    elevationLow: elevationLow ?? this.elevationLow,
    elevationMed: elevationMed ?? this.elevationMed,
    spacingSmall: spacingSmall ?? this.spacingSmall,
    spacingMedium: spacingMedium ?? this.spacingMedium,
    spacingLarge: spacingLarge ?? this.spacingLarge,
    primaryBrand: primaryBrand ?? this.primaryBrand,
    accentSuccess: accentSuccess ?? this.accentSuccess,
    accentWarning: accentWarning ?? this.accentWarning,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    fontFamilyPrimary: fontFamilyPrimary ?? this.fontFamilyPrimary,
    fontFamilySecondary: fontFamilySecondary ?? this.fontFamilySecondary,
    fontWeightRegular: fontWeightRegular ?? this.fontWeightRegular,
    fontWeightMedium: fontWeightMedium ?? this.fontWeightMedium,
    fontWeightSemiBold: fontWeightSemiBold ?? this.fontWeightSemiBold,
    textScaleHeadline: textScaleHeadline ?? this.textScaleHeadline,
    textScaleBody: textScaleBody ?? this.textScaleBody,
    textScaleCaption: textScaleCaption ?? this.textScaleCaption,
  );

  @override
  BrandTheme lerp(ThemeExtension<BrandTheme>? other, double t) {
    if (other is! BrandTheme) return this;
    return BrandTheme(
      brandName: t < .5 ? brandName : other.brandName,
      radius: lerpDouble(radius, other.radius, t) ?? radius,
      elevationLow:
          lerpDouble(elevationLow, other.elevationLow, t) ?? elevationLow,
      elevationMed:
          lerpDouble(elevationMed, other.elevationMed, t) ?? elevationMed,
      spacingSmall:
          lerpDouble(spacingSmall, other.spacingSmall, t) ?? spacingSmall,
      spacingMedium:
          lerpDouble(spacingMedium, other.spacingMedium, t) ?? spacingMedium,
      spacingLarge:
          lerpDouble(spacingLarge, other.spacingLarge, t) ?? spacingLarge,
      primaryBrand:
          Color.lerp(primaryBrand, other.primaryBrand, t) ?? primaryBrand,
      accentSuccess:
          Color.lerp(accentSuccess, other.accentSuccess, t) ?? accentSuccess,
      accentWarning:
          Color.lerp(accentWarning, other.accentWarning, t) ?? accentWarning,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      fontFamilyPrimary: t < .5 ? fontFamilyPrimary : other.fontFamilyPrimary,
      fontFamilySecondary: t < .5
          ? fontFamilySecondary
          : other.fontFamilySecondary,
      fontWeightRegular: t < .5 ? fontWeightRegular : other.fontWeightRegular,
      fontWeightMedium: t < .5 ? fontWeightMedium : other.fontWeightMedium,
      fontWeightSemiBold: t < .5
          ? fontWeightSemiBold
          : other.fontWeightSemiBold,
      textScaleHeadline:
          lerpDouble(textScaleHeadline, other.textScaleHeadline, t) ??
          textScaleHeadline,
      textScaleBody:
          lerpDouble(textScaleBody, other.textScaleBody, t) ?? textScaleBody,
      textScaleCaption:
          lerpDouble(textScaleCaption, other.textScaleCaption, t) ??
          textScaleCaption,
    );
  }
}

/// Build a ThemeData for UI v2, centralizing brand palette and typography.
ThemeData buildThemeV2({Brightness brightness = Brightness.dark}) {
  final dark = brightness == Brightness.dark;
  final base = ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: dark
        ? AppColors.neutralBg
        : AppColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBrand,
      brightness: brightness,
      primary: AppColors.primaryBrand,
      secondary: AppColors.accentSuccess,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    textTheme: const TextTheme(
      titleLarge: AppTypography.h1,
      titleMedium: AppTypography.h3,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.label,
      labelSmall: AppTypography.caption,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 1,
      backgroundColor: AppColors.surfaceVariant,
      foregroundColor: AppColors.textPrimaryDark,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBrand,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        elevation: 2,
      ),
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    extensions: const <ThemeExtension<dynamic>>[BrandTheme()],
  );
}
