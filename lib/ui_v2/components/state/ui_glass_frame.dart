import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

/// A reusable helper that wraps content with the premium glass decoration used
/// for various SSOT state displays.
class UiGlassFrame extends StatelessWidget {
  const UiGlassFrame({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.gradientColors,
    this.gradientStops,
    this.borderColor,
    this.borderWidth = 1,
    this.emphasized = false,
    this.disabled = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final Color? borderColor;
  final double borderWidth;
  final bool emphasized;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ??
        [
          AppColors.surface.withOpacity(disabled ? 0.55 : 0.7),
          AppColors.surfaceVariant.withOpacity(disabled ? 0.82 : 0.92),
        ];
    final stops = gradientStops ?? const [0.0, 1.0];
    final decoratedChild = disabled
        ? Opacity(opacity: 0.75, child: child)
        : child;
    final shadows = [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];
    if (emphasized) {
      shadows.add(
        BoxShadow(
          color: SharkyTokensV1.brandPrimary.withOpacity(0.3),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      );
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusLg),
        gradient: LinearGradient(
          colors: colors,
          stops: stops,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.14),
          width: borderWidth,
        ),
        boxShadow: shadows,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: decoratedChild,
      ),
    );
  }
}

class GlassSurfaceSpec {
  const GlassSurfaceSpec({
    required this.baseGradient,
    required this.specularGradient,
    required this.borderColor,
    required this.borderWidth,
    required this.shadows,
  });

  final Gradient baseGradient;
  final Gradient specularGradient;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;

  BoxDecoration decoration({BorderRadius? radius}) {
    return BoxDecoration(
      gradient: baseGradient,
      borderRadius: radius ?? BorderRadius.circular(SharkyTokensV1.radiusLg),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: shadows,
    );
  }
}

final GlassSurfaceSpec kPremiumGlassSurfaceSpec = GlassSurfaceSpec(
  baseGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.surface.withOpacity(0.85),
      AppColors.surfaceVariant.withOpacity(0.95),
    ],
  ),
  specularGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white.withOpacity(0.12), Colors.transparent],
    stops: [0.0, 0.85],
  ),
  borderColor: Colors.white.withOpacity(0.15),
  borderWidth: 1.2,
  shadows: [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ],
);
