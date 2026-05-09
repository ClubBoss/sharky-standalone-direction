import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _gestureRadius = 16.0;
final List<BoxShadow> _gestureShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationGesturePreviewLayer extends StatelessWidget {
  const SimulationGesturePreviewLayer({super.key});

  Widget _gestureBlock(String label) {
    return Container(
      width: 60,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.body.copyWith(color: AppColors.textPrimaryDark),
        ),
      ),
    );
  }

  Widget _arrowBlock() {
    return Text(
      '→',
      style: AppTypography.body.copyWith(color: AppColors.textPrimaryDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_gestureRadius),
        boxShadow: _gestureShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gesture Preview',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _gestureBlock('Tap'),
              _arrowBlock(),
              _gestureBlock('Swipe'),
            ],
          ),
        ],
      ),
    );
  }
}
