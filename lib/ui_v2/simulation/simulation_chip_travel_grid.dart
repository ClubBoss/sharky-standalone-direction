import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

const double _gridRadius = 20.0;
final List<BoxShadow> _gridShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationChipTravelGrid extends StatelessWidget {
  const SimulationChipTravelGrid({super.key});

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.textSecondaryDark.withOpacity(0.35),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_dot(), _dot(), _dot()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_gridRadius),
        boxShadow: _gridShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _row(),
          SizedBox(height: AppSpacing.xs),
          _row(),
          const SizedBox(height: AppSpacing.xs),
          _row(),
        ],
      ),
    );
  }
}
