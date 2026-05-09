import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _blockRadius = 8.0;
final List<BoxShadow> _blockShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
];

class SimulationCardDealingPreview extends StatelessWidget {
  const SimulationCardDealingPreview({super.key});

  Widget _cardBlock() {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_blockRadius),
        boxShadow: _blockShadow,
      ),
    );
  }

  Widget _seatBlock() {
    return Container(
      width: 60,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_blockRadius),
        boxShadow: _blockShadow,
      ),
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
            'Card Dealing Preview',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cardBlock(),
              Text(
                '→',
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              _seatBlock(),
            ],
          ),
        ],
      ),
    );
  }
}
