import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _chipRadius = 12.0;
final List<BoxShadow> _chipShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationPotChipStackLayer extends StatelessWidget {
  const SimulationPotChipStackLayer({super.key});

  Widget _chipPlaceholder() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_chipRadius),
        boxShadow: _chipShadow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_chipRadius),
        boxShadow: _chipShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Chip Stack',
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chipPlaceholder(),
              SizedBox(width: AppSpacing.sm),
              _chipPlaceholder(),
              SizedBox(width: AppSpacing.sm),
              _chipPlaceholder(),
            ],
          ),
        ],
      ),
    );
  }
}
