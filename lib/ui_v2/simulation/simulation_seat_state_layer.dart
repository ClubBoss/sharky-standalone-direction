import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

enum SeatState { hero, active, empty }

class SimulationSeatStateLayer extends StatelessWidget {
  const SimulationSeatStateLayer({
    super.key,
    required this.state,
    this.label = 'Seat',
  });

  final SeatState state;
  final String label;

  Color get _borderColor {
    switch (state) {
      case SeatState.hero:
        return AppColors.textSecondaryDark;
      case SeatState.active:
        return AppColors.textPrimaryDark;
      case SeatState.empty:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _borderColor, width: 2),
      ),
      child: Center(
        child: Text(
          state == SeatState.empty ? 'Empty Seat' : label,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: AppColors.textPrimaryDark),
        ),
      ),
    );
  }
}
