import 'package:flutter/material.dart';

import '../design/design_typography.dart';
import '../../engine/motion_frame_composer.dart';
import '../../engine/motion_playback_adapter.dart';
import '../../engine/motion/motion_variance_audit.dart';
import '../../ui_v3/theme/visual_theme_v3.dart';

class ChannelInspectorOverlay extends StatelessWidget {
  const ChannelInspectorOverlay({
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
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 210,
            constraints: const BoxConstraints(maxHeight: 220),
            margin: EdgeInsets.only(
              top: VisualThemeV3.spacingM,
              left: VisualThemeV3.spacingM,
            ),
            padding: EdgeInsets.all(VisualThemeV3.spacingS),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
              border: Border.all(color: Colors.white24),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Channel Inspector',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DesignTypography.caption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...entries.map((entry) {
                    final sample = entry.value;
                    final progress = sample?.progress ?? 0.0;
                    final formatted = (progress).toStringAsFixed(2);
                    final variance = audit?.varianceFor(entry.key) ?? 0.0;
                    final varText = variance > 0
                        ? ' / var ${variance.toStringAsFixed(3)}'
                        : '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '${entry.key}: $formatted$varText',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
