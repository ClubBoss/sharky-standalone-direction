import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

/// Badge displaying the name of the current street.
class StreetIndicator extends StatelessWidget {
  final int street;
  const StreetIndicator({Key? key, required this.street}) : super(key: key);

  static const _names = ['Preflop', 'Flop', 'Turn', 'River'];

  @override
  Widget build(BuildContext context) {
    final name = _names[street.clamp(0, _names.length - 1)];
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(name),
          margin: const EdgeInsets.only(top: VisualThemeV3.spacingS),
          padding: const EdgeInsets.symmetric(
            horizontal: VisualThemeV3.spacingM,
            vertical: VisualThemeV3.spacingS,
          ),
          decoration: BoxDecoration(
            color: VisualThemeV3.card.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
            boxShadow: const [VisualThemeV3.shadowLight],
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: VisualThemeV3.spacingS),
                decoration: BoxDecoration(
                  color: VisualThemeV3.accent,
                  shape: BoxShape.circle,
                  boxShadow: const [VisualThemeV3.shadowLight],
                ),
              ),
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: VisualThemeV3.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
