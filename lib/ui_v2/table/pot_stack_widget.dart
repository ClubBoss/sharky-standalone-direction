import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class PotStackWidget extends StatelessWidget {
  const PotStackWidget({required this.amount, super.key});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(VisualThemeV3.spacingS),
      decoration: BoxDecoration(
        color: VisualThemeV3.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        boxShadow: const [VisualThemeV3.shadowLight],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: List<Widget>.generate(
                3,
                (index) => Positioned(
                  top: index * 6.0,
                  child: Container(
                    width: 32,
                    height: 16,
                    decoration: BoxDecoration(
                      color: VisualThemeV3.accent.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(
                        VisualThemeV3.spacingXS,
                      ),
                      boxShadow: const [VisualThemeV3.shadowLight],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: VisualThemeV3.spacingS),
          Text(
            amount == 0 ? 'Pot: []' : 'Pot: ${amount.toInt()}',
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
