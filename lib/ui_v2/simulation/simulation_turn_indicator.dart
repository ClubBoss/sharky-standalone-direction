import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _indicatorRadius = 12.0;
final List<BoxShadow> _indicatorShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 10,
    offset: const Offset(0, 3),
  ),
];

class SimulationTurnIndicator extends StatelessWidget {
  const SimulationTurnIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_indicatorRadius),
        boxShadow: _indicatorShadow,
      ),
      child: Text(
        'TURN',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }
}
