import 'package:flutter/material.dart';

import 'package:poker_analyzer/engine/motion_frame_composer.dart';
import 'package:poker_analyzer/engine/motion_playback_adapter.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class ChannelTimelineOverlay extends StatelessWidget {
  const ChannelTimelineOverlay({
    super.key,
    required this.snapshot,
    required this.enabled,
  });

  final MotionFrameSnapshot? snapshot;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || snapshot == null) {
      return const SizedBox.shrink();
    }
    final entries = <String, MotionPlaybackSample?>{};
    entries.addAll(snapshot!.channels.seat);
    entries.addAll(snapshot!.channels.board);
    entries.addAll(snapshot!.channels.pot);
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(
              top: VisualThemeV3.spacingM,
              right: VisualThemeV3.spacingM,
            ),
            padding: const EdgeInsets.all(VisualThemeV3.spacingS),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: entries.entries.map((entry) {
                final progress = (entry.value?.progress ?? 0.0).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
