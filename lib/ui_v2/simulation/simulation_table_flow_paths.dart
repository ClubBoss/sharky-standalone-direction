import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _flowRadius = 16.0;
final List<BoxShadow> _flowShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationTableFlowPaths extends StatelessWidget {
  const SimulationTableFlowPaths({super.key});

  Widget _pathBlock() {
    return Container(
      width: 60,
      height: 12,
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
        borderRadius: BorderRadius.circular(_flowRadius),
        boxShadow: _flowShadow,
      ),
      child: Column(
        children: [
          Text(
            'Flow Paths',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_pathBlock(), _pathBlock(), _pathBlock()],
          ),
        ],
      ),
    );
  }
}
