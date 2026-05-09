import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

const double _guideRadius = 16.0;
final List<BoxShadow> _guideShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationDealerRotationGuide extends StatelessWidget {
  const SimulationDealerRotationGuide({super.key});

  Widget _marker() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: AppColors.textPrimaryDark,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_guideRadius),
        boxShadow: _guideShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _marker(),
          SizedBox(width: AppSpacing.md),
          _marker(),
          SizedBox(width: AppSpacing.md),
          _marker(),
        ],
      ),
    );
  }
}
