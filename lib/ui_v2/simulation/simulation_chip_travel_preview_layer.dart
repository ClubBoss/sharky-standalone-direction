import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _chipRadius = 18.0;
final List<BoxShadow> _chipShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
];

const double _seatRadius = 8.0;
final List<BoxShadow> _seatShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
];

class SimulationChipTravelPreviewLayer extends StatelessWidget {
  const SimulationChipTravelPreviewLayer({super.key});

  Widget _chipBlock() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: _chipShadow,
      ),
    );
  }

  Widget _seatBlock() {
    return Container(
      width: 60,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_seatRadius),
        boxShadow: _seatShadow,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chip Travel Preview',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_chipBlock(), _arrowBlock(), _seatBlock()],
          ),
        ],
      ),
    );
  }
}
