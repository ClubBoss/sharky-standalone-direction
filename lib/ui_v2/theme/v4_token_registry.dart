import 'package:flutter/material.dart';

class V4TokenRegistry {
  const V4TokenRegistry();

  double get v4RadiusBase => 13.0;
  double get v4ShadowBase => 6.0;
  double get v4ContrastLevel => 1.2;
  double get v4SurfaceTint => 0.08;
  double get v4FontSizeScale => 1.04;
  double get v4FontWeightDelta => 0.25;
  double get v4IconTone => 0.92;
  double get v4MotionAlpha => 0.05;
  double get v4MotionShift => 0.35;
  double get v4MotionOverlay => 0.08;
  double get v4ElevLow => 2.0;
  double get v4ElevMed => v4ElevLow + 1.0;
  double get v4ElevHigh => v4ElevMed + 1.0;
  double get v4SpacingSmall => 9.0;
  double get v4SpacingMedium => 17.0;
  double get v4SpacingLarge => 23.0;
  double get cardHoverOffset => 2.0;
  double get cardHoverElevation => 2.0;
  double get v4SpacingXS => 4.0;
  double get v4SpacingS => 8.0;
  double get v4SpacingM => 12.0;
  double get v4SpacingL => 16.0;
  double get v4RadiusM => 12.0;
  double get v4ShadowBlur => 8.0;
  double get v4ShadowOpacity => 0.10;

  double get v4FontScaleBody => 1.04;
  double get v4FontScaleTitle => 1.08;
  int get v4FontWeightBody => 2;
  int get v4FontWeightTitle => 1;
  double get v4LetterSpacingDelta => 0.02;
  double get v4SurfaceNeutralLow => 0.97;
  double get v4SurfaceNeutralHigh => 1.03;
  double get v4RoleAccentTone => 1.01;
  double get cardPadding => v4SpacingSmall;
  double get cardRadius => v4RadiusBase;
  Duration get motionShort => const Duration(milliseconds: 140);
  Color get tableSurfaceColor => const Color(0xFFF2F4F7);
  double get tableSurfaceElevation => v4ElevLow;
  double get tableSurfaceRadius => v4RadiusBase;
  double get v4SurfaceSpacingFinal => v4SpacingSmall.clamp(6.0, 24.0);
  double get v4SurfaceRadiusFinal => v4RadiusBase.clamp(8.0, 18.0);
  double get v4SurfaceShadowFinal => v4ElevLow.clamp(1.0, 8.0);
  Color get v4SurfaceColorFinal => tableSurfaceColor.withValues(alpha: 0.98);
  double get v4SurfacePolishPadding => v4SurfaceSpacingFinal;
  double get v4SurfacePolishRadius => v4SurfaceRadiusFinal;
  double get v4SurfacePolishShadow => v4SurfaceShadowFinal;
  Color get v4SurfacePolishAccent =>
      const Color(0xFF0A5DC2).withValues(alpha: 0.92);
  double get v4FinalRadius => v4SurfaceRadiusFinal;
  double get v4FinalPadding => v4SurfaceSpacingFinal;
  double get v4FinalShadow => v4SurfaceShadowFinal;
  Color get v4FinalAccentColor =>
      const Color(0xFF0A5DC2).withValues(alpha: 0.9);
  Color get v4FinalSurfaceColor => tableSurfaceColor.withValues(alpha: 0.99);
  double get v4FontSizeBody => 14.0;
  double get v4FontSizeTitle => 20.0;
  double get v4LetterSpacingBody => 0.15;
  double get v4LetterSpacingTitle => 0.10;
  double get v4IconSizeS => 16.0;
  double get v4IconSizeM => 20.0;
  double get v4IconSizeL => 24.0;
  double get v4IconPadding => 4.0;
  double get v4IconOpacity => 0.90;
  double get v4IconPaddingS => v4IconPadding;
  double get v4ShadowOffset => 2.0;
  double get v4RadiusS => 8.0;
  double get v4MotionLiftOffset => v4MotionOffsetS;
  Duration get v4MotionDurationXS => const Duration(milliseconds: 80);
  Duration get v4MotionDurationS => const Duration(milliseconds: 120);
  Duration get v4MotionDurationM => const Duration(milliseconds: 180);
  Curve get v4MotionCurve => Curves.easeInOut;
  double get v4MotionOffsetXS => 0.02;
  double get v4MotionOffsetS => 0.04;

  Map<String, double> get spacingTokens => {
    'v4SpacingSmall': v4SpacingSmall,
    'v4SpacingMedium': v4SpacingMedium,
    'v4SpacingLarge': v4SpacingLarge,
    'v4SpacingXS': v4SpacingXS,
    'v4SpacingS': v4SpacingS,
    'v4SpacingM': v4SpacingM,
    'v4SpacingL': v4SpacingL,
  };

  Map<String, double> get radiusTokens => {
    'v4RadiusBase': v4RadiusBase,
    'v4RadiusM': v4RadiusM,
  };

  Map<String, double> get elevationTokens => {
    'v4ElevLow': v4ElevLow,
    'v4ElevMed': v4ElevMed,
    'v4ElevHigh': v4ElevHigh,
  };

  Map<String, double> get typographyTokens => {
    'v4FontScaleBody': v4FontScaleBody,
    'v4FontScaleTitle': v4FontScaleTitle,
    'v4LetterSpacingDelta': v4LetterSpacingDelta,
    'v4FontWeightBody': v4FontWeightBody.toDouble(),
    'v4FontWeightTitle': v4FontWeightTitle.toDouble(),
  };
}
