import 'package:flutter/material.dart';

import 'package:poker_analyzer/theme/theme_v2.dart';

class SectionSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SectionSurface({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    final background = theme.colorScheme.surfaceVariant;
    final borderColor = theme.colorScheme.outline;
    final spacing = brand?.spacingMedium ?? 16;
    final radius = brand?.radius ?? 12;
    final blur = brand?.elevationLow ?? 2;
    final resolvedPadding = padding ?? EdgeInsets.all(spacing);
    return Container(
      margin: margin,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: blur,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
