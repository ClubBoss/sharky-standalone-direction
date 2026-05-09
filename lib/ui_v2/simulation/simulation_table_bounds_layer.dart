import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _boundsRadius = 12.0;
const List<BoxShadow> _boundsShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
];

class SimulationTableBoundsLayer extends StatelessWidget {
  const SimulationTableBoundsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_boundsRadius),
        border: Border.all(color: AppColors.textSecondaryDark, width: 1),
        boxShadow: _boundsShadow,
      ),
      child: Center(
        child: Text(
          'Bounds Frame',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
