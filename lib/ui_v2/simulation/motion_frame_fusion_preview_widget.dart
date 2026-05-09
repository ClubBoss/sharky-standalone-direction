import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

import '../../engine/motion_surface_player.dart';
import '../../engine/ui_motion_tick_engine.dart';

class MotionFrameFusionPreviewWidget extends StatelessWidget {
  const MotionFrameFusionPreviewWidget({
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
    final len = min(surface.length, ticks.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < len; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              '${_formatFrame(surface[i])}:${ticks[i].frames.map((f) => f.label).toList()}',
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimaryDark,
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
