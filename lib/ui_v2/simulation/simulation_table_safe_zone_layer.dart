import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _zoneRadius = 20.0;
final List<BoxShadow> _zoneShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 14,
    offset: const Offset(0, 5),
  ),
];

class SimulationTableSafeZoneLayer extends StatelessWidget {
  const SimulationTableSafeZoneLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(_zoneRadius),
        boxShadow: _zoneShadow,
      ),
      child: Center(
        child: Text(
          'Safe Zone',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
