import 'package:flutter/material.dart';

import 'package:poker_analyzer/engine/motion_playback_adapter.dart';
import 'package:poker_analyzer/engine/motion_frame_composer.dart';

/// Developer-only overlay that shows the current motion channel dots.
class ChannelCohesionPreview extends StatelessWidget {
  const ChannelCohesionPreview({
    super.key,
    required this.snapshot,
    required this.beat,
    required this.enabled,
  });

  final MotionFrameSnapshot? snapshot;
  final double beat;
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
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _ChannelCohesionPainter(entries)),
      ),
    );
  }
}

class _ChannelCohesionPainter extends CustomPainter {
  _ChannelCohesionPainter(this.entries);

  static final Map<String, Offset> _lastPositions = {};
  final Map<String, MotionPlaybackSample?> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.15);
    entries.forEach((id, sample) {
      if (sample == null) {
        return;
      }
      final offset = Offset(sample.x, sample.y);
      final color = id.startsWith('pot:winner')
          ? Colors.cyanAccent
          : id.startsWith('deal:preflop:')
          ? Colors.amberAccent
          : Colors.white.withOpacity(0.25);
      dotPaint.color = color;
      canvas.drawCircle(offset, 4.0, dotPaint);
      final prev = _lastPositions[id];
      if (prev != null) {
        canvas.drawLine(prev, offset, trailPaint);
      }
      _lastPositions[id] = offset;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
