import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class TableSurface extends StatelessWidget {
  const TableSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = Color.lerp(
      theme.cardColor,
      theme.colorScheme.surface,
      0.08,
    );
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: VisualThemeV3.spacingS,
        vertical: VisualThemeV3.spacingM,
      ),
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        boxShadow: const [
          VisualThemeV3.shadowLight,
          VisualThemeV3.shadowMedium,
        ],
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }
}
