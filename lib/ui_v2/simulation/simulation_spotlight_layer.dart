import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _spotRadius = 24.0;
final List<BoxShadow> _spotShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 24,
    offset: const Offset(0, 8),
  ),
];

class SimulationSpotlightLayer extends StatelessWidget {
  const SimulationSpotlightLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_spotRadius),
        boxShadow: _spotShadow,
      ),
      child: Center(
        child: Text(
          'Spotlight',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
