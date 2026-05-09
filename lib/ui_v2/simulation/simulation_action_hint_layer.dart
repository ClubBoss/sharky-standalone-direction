import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../design/design_typography.dart';

class SimulationActionHintLayer extends StatelessWidget {
  const SimulationActionHintLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.10)),
        boxShadow: const [VisualThemeV3.shadowMedium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Action: —',
            style: TextStyle(
              fontSize: DesignTypography.body,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: VisualThemeV3.spacingS),
          Text(
            'Hint: —',
            style: TextStyle(
              fontSize: DesignTypography.body,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
