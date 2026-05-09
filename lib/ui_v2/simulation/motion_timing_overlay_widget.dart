import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

import '../../engine/motion_surface_player.dart';
import '../../engine/ui_motion_tick_engine.dart';

class MotionTimingOverlayWidget extends StatelessWidget {
  const MotionTimingOverlayWidget({
    super.key,
    required this.player,
    required this.tickEngine,
  });

  final MotionSurfacePlayer player;
  final UiMotionTickEngine tickEngine;

  @override
  Widget build(BuildContext context) {
    final surface = player.flow();
    final ticks = tickEngine.buildTicks();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Surface Count: ${surface.length}',
          style: AppTypography.body.copyWith(color: AppColors.textPrimaryDark),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tick Count: ${ticks.length}',
          style: AppTypography.body.copyWith(color: AppColors.textPrimaryDark),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Δ(len): ${surface.length - ticks.length}',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}
