import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

const double _fanRadius = 20.0;
final List<BoxShadow> _fanShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationCardFanLayer extends StatelessWidget {
  const SimulationCardFanLayer({super.key});

  Widget _fanCard() {
    return Container(
      width: 40,
      height: 58,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
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
        borderRadius: BorderRadius.circular(_fanRadius),
        boxShadow: _fanShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_fanCard(), _fanCard(), _fanCard(), _fanCard(), _fanCard()],
      ),
    );
  }
}
