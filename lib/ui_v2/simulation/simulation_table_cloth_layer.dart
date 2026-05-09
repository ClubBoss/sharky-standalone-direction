import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _clothRadius = 16.0;
final List<BoxShadow> _clothShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 20,
    offset: const Offset(0, 6),
  ),
];

class SimulationTableClothLayer extends StatelessWidget {
  const SimulationTableClothLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_clothRadius),
        boxShadow: _clothShadow,
      ),
      child: Center(
        child: Text(
          'Table Surface',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
