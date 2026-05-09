import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

import '../../engine/motion_surface_player.dart';

class MotionSurfaceWidget extends StatelessWidget {
  const MotionSurfaceWidget({super.key, required this.player});

  final MotionSurfacePlayer player;

  @override
  Widget build(BuildContext context) {
    final flow = player.flow();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in flow)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              '${entry['timestamp']}: ${entry['frames']}',
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
      ],
    );
  }
}
