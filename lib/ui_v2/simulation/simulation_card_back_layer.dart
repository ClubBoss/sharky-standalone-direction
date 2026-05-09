import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _cardRadius = 8.0;
final List<BoxShadow> _cardShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationCardBackLayer extends StatelessWidget {
  const SimulationCardBackLayer({super.key});

  Widget _card() {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      child: Center(
        child: Text(
          'Back',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _card(),
        SizedBox(width: AppSpacing.sm),
        _card(),
        SizedBox(width: AppSpacing.sm),
        _card(),
      ],
    );
  }
}
