import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _layerRadius = 12.0;
final List<BoxShadow> _layerShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class SimulationCommunityCardsLayer extends StatelessWidget {
  const SimulationCommunityCardsLayer({super.key});

  List<Widget> _buildCardPlaceholders() {
    return List.generate(3, (_) {
      return Container(
        width: 60,
        height: 90,
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_layerRadius),
          boxShadow: _layerShadow,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_layerRadius),
        boxShadow: _layerShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Community Cards',
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildCardPlaceholders(),
          ),
        ],
      ),
    );
  }
}
