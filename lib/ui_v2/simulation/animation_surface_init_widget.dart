import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

import '../../engine/motion_surface_player.dart';

class AnimationSurfaceInitWidget extends StatelessWidget {
  const AnimationSurfaceInitWidget({super.key, required this.player});

  final MotionSurfacePlayer player;

  @override
  Widget build(BuildContext context) {
    final flow = player.flow();
    final preview = flow.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Animation Surface Preview',
          style: AppTypography.body.copyWith(color: AppColors.textPrimaryDark),
        ),
        SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < preview.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              'frame_$i: ${_formatFrame(preview[i])}',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
      ],
    );
  }

  String _formatFrame(dynamic frame) {
    if (frame is Map) {
      return frame.entries.map((e) => '${e.key}:${e.value}').join(', ');
    }
    if (frame is Iterable) {
      return frame.join(', ');
    }
    return frame.toString();
  }
}
