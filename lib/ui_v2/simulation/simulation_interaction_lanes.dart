import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

const double _laneRadius = 20.0;
final List<BoxShadow> _laneShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 10,
    offset: const Offset(0, 3),
  ),
];

class SimulationInteractionLanes extends StatelessWidget {
  const SimulationInteractionLanes({super.key});

  Widget _lane() {
    return Container(
      width: 4,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.textSecondaryDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_laneRadius),
        boxShadow: _laneShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_lane(), _lane(), _lane()],
      ),
    );
  }
}
