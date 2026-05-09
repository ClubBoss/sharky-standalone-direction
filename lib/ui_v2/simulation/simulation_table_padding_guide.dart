import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _guideRadius = 16.0;
final List<BoxShadow> _guideShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 10,
    offset: const Offset(0, 3),
  ),
];

class SimulationTablePaddingGuide extends StatelessWidget {
  const SimulationTablePaddingGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_guideRadius),
        boxShadow: _guideShadow,
      ),
      child: Center(
        child: Text(
          'Padding Guide',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
