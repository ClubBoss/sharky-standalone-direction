import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _markerRadius = 12.0;
final List<BoxShadow> _markerShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 10,
    offset: const Offset(0, 3),
  ),
];

class SimulationBlindMarkersLayer extends StatelessWidget {
  const SimulationBlindMarkersLayer({super.key});

  Widget _marker(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_markerRadius),
        boxShadow: _markerShadow,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_marker('SB'), _marker('BB')],
    );
  }
}
