import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

const double _zoneRadius = 16.0;
final List<BoxShadow> _zoneShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationChipDropZones extends StatelessWidget {
  const SimulationChipDropZones({super.key});

  Widget _zone() {
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_zoneRadius),
        boxShadow: _zoneShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _zone(),
          SizedBox(width: AppSpacing.md),
          _zone(),
          SizedBox(width: AppSpacing.md),
          _zone(),
        ],
      ),
    );
  }
}
