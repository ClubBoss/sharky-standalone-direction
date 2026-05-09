import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';

import 'ui_glass_frame.dart';

class UiGlassTapSurface extends StatelessWidget {
  const UiGlassTapSurface({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.gradientColors,
    this.gradientStops,
    this.borderColor,
    this.borderWidth = 1,
    this.emphasized = false,
    this.disabled = false,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final Color? borderColor;
  final double borderWidth;
  final bool emphasized;
  final bool disabled;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius =
        borderRadius ?? BorderRadius.circular(SharkyTokensV1.radiusLg);
    return Material(
      color: Colors.transparent,
      borderRadius: resolvedRadius,
      child: InkWell(
        borderRadius: resolvedRadius,
        onTap: disabled ? null : onTap,
        child: UiGlassFrame(
          margin: margin,
          padding: padding,
          gradientColors: gradientColors,
          gradientStops: gradientStops,
          borderColor: borderColor,
          borderWidth: borderWidth,
          emphasized: emphasized,
          disabled: disabled,
          child: child,
        ),
      ),
    );
  }
}
