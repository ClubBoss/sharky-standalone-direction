import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _ringRadius = 48.0;
final List<BoxShadow> _ringShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 20,
    offset: const Offset(0, 6),
  ),
];

class SimulationTableRingLayer extends StatelessWidget {
  const SimulationTableRingLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_ringRadius),
        boxShadow: _ringShadow,
      ),
      child: Center(
        child: Text(
          'Table Ring',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
