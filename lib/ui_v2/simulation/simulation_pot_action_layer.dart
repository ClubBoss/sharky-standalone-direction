import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _layerRadius = 12.0;

const List<BoxShadow> _layerShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
];

class SimulationPotActionLayer extends StatelessWidget {
  const SimulationPotActionLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_layerRadius),
        boxShadow: _layerShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pot: 0',
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(_layerRadius),
              boxShadow: _layerShadow,
            ),
            child: Center(
              child: Text(
                'Action Bar',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
