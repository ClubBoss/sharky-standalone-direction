import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _anchorRadius = 12.0;
final List<BoxShadow> _anchorShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
];

class SimulationDealerAnchor extends StatelessWidget {
  const SimulationDealerAnchor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_anchorRadius),
        boxShadow: _anchorShadow,
      ),
      child: Text(
        'DEALER',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }
}
