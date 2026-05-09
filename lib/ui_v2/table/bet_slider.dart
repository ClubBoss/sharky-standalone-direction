import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class BetSlider extends StatelessWidget {
  const BetSlider({required this.value, required this.onChanged, super.key});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        boxShadow: const [VisualThemeV3.shadowLight],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: value,
            onChanged: onChanged,
            min: 0,
            max: 100,
            activeColor: VisualThemeV3.accent,
            inactiveColor: VisualThemeV3.secondaryText.withValues(alpha: 0.35),
          ),
          const SizedBox(height: VisualThemeV3.spacingS),
          Text(
            'Bet: ${value.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: VisualThemeV3.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
