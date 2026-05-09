import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

const double _gridRadius = 16.0;
final List<BoxShadow> _gridShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationTableGuideGrid extends StatelessWidget {
  const SimulationTableGuideGrid({super.key});

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.textSecondaryDark.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_dot(), _dot(), _dot()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_gridRadius),
        boxShadow: _gridShadow,
      ),
      child: Column(
        children: [
          _row(),
          SizedBox(height: AppSpacing.xs),
          _row(),
          SizedBox(height: AppSpacing.xs),
          _row(),
        ],
      ),
    );
  }
}
