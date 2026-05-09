import '../motion_frame_composer.dart';
import '../motion_playback_adapter.dart';
import 'motion_variance_audit.dart';

class MotionBreakpointConfig {
  const MotionBreakpointConfig({
    required this.enabled,
    this.varianceLimit,
    this.progressLimit,
    this.idContains,
  });

  final bool enabled;
  final double? varianceLimit;
  final double? progressLimit;
  final String? idContains;
}

class MotionBreakpoint {
  bool check(
    MotionFrameSnapshot? snapshot,
    MotionVarianceAudit? audit,
    MotionBreakpointConfig cfg,
  ) {
    if (!cfg.enabled || snapshot == null) {
      return false;
    }
    final entries = <MapEntry<String, MotionPlaybackSample?>>[
      ...snapshot.channels.seat.entries,
      ...snapshot.channels.board.entries,
      ...snapshot.channels.pot.entries,
    ];
    for (final entry in entries) {
      if (cfg.idContains != null && !entry.key.contains(cfg.idContains!)) {
        continue;
      }
      final variance = audit?.varianceFor(entry.key) ?? 0.0;
      if (cfg.varianceLimit != null && variance >= cfg.varianceLimit!) {
        return true;
      }
      final sample = entry.value;
      if (sample == null) {
        continue;
      }
      if (cfg.progressLimit != null && sample.progress >= cfg.progressLimit!) {
        return true;
      }
    }
    return false;
  }
}
