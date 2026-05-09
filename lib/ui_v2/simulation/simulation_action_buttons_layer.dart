import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _buttonRadius = 12.0;
const List<BoxShadow> _buttonShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
];

class SimulationActionButtonsLayer extends StatelessWidget {
  const SimulationActionButtonsLayer({super.key});

  Widget _buildButtonLabel(String label) {
    return Container(
      width: 80,
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_buttonRadius),
        boxShadow: _buttonShadow,
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_buttonRadius),
        boxShadow: _buttonShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonLabel('Fold'),
          _buildButtonLabel('Check'),
          _buildButtonLabel('Bet'),
        ],
      ),
    );
  }
}
