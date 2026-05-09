import 'package:flutter/material.dart';

import 'package:poker_analyzer/engine/motion_frame_composer.dart';
import 'package:poker_analyzer/engine/motion_playback_adapter.dart';
import 'package:poker_analyzer/engine/motion/motion_variance_audit.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class ChannelHeatmapOverlay extends StatelessWidget {
  const ChannelHeatmapOverlay({
    super.key,
    required this.snapshot,
    required this.audit,
    required this.enabled,
  });

  final MotionFrameSnapshot? snapshot;
  final MotionVarianceAudit? audit;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || snapshot == null) {
      return const SizedBox.shrink();
    }
    final entries = <MapEntry<String, MotionPlaybackSample?>>[
      ...snapshot!.channels.seat.entries,
      ...snapshot!.channels.board.entries,
      ...snapshot!.channels.pot.entries,
    ];
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    Color colorFor(double variance) {
      if (variance <= 0.01) {
        return Colors.greenAccent.withOpacity(0.35);
      }
      if (variance <= 0.03) {
        return Colors.orangeAccent.withOpacity(0.35);
      }
      return Colors.redAccent.withOpacity(0.35);
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 170,
            constraints: const BoxConstraints(maxHeight: 200),
            margin: EdgeInsets.only(
              top: VisualThemeV3.spacingM,
              right: VisualThemeV3.spacingM,
            ),
            padding: EdgeInsets.all(VisualThemeV3.spacingS),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.40),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
              border: Border.all(color: Colors.white24),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Channel Heatmap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...entries.map((entry) {
                    final variance = audit?.varianceFor(entry.key) ?? 0.0;
                    final barColor = colorFor(variance);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
