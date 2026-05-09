import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

import '../../engine/ui_motion_tick_engine.dart';

class MotionTickPreviewWidget extends StatelessWidget {
  const MotionTickPreviewWidget({super.key, required this.engine});

  final UiMotionTickEngine engine;

  @override
  Widget build(BuildContext context) {
    final ticks = engine.buildTicks();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tick in ticks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              '${tick.tick}: ${tick.frames.map((f) => f.label).toList()}',
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
      ],
    );
  }
}
