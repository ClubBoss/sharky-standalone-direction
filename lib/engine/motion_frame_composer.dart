import 'dart:math' as math;

import 'motion_channel_playback_resolver.dart';
import 'animation_orchestrator_context.dart';
import 'motion_timeline_assembler.dart';

class MotionFrameSnapshot {
  const MotionFrameSnapshot({
    required this.timeMs,
    required this.channels,
    required this.timelineValue,
  });

  final double timeMs;
  final MotionChannelPlaybackSnapshot channels;
  final double timelineValue;
}

class MotionFrameComposer {
  MotionFrameComposer(this.resolver, this.orchestrator)
    : _lastNormalizedProgress = {};

  final MotionChannelPlaybackResolver resolver;
  final AnimationOrchestratorContext orchestrator;
  final Map<String, double> _lastNormalizedProgress;
  static const double _kMaxLead = 0.004;

  MotionFrameSnapshot compose(double timeMs) {
    final channels = resolver.resolve(timeMs);
    final tv = _normalizedTimelineValue(timeMs);
    return MotionFrameSnapshot(
      timeMs: timeMs,
      channels: channels,
      timelineValue: tv,
    );
  }

  double _normalizedTimelineValue(double timeMs) {
    final timeline = resolver.input.timeline;
    if (timeline.isEmpty) {
      return orchestrator.timelineValue;
    }
    final lastEntry = timeline.last;
    final duration = lastEntry.startMs + lastEntry.spec.durationMs;
    final targetTime = timeMs.clamp(0.0, duration);
    MotionTimelineEntry? activeEntry;
    for (final entry in timeline) {
      final entryEnd = entry.startMs + entry.spec.durationMs;
      if (targetTime >= entry.startMs && targetTime <= entryEnd) {
        activeEntry = entry;
        break;
      }
    }
    activeEntry ??= timeline.last;
    final rawProgress = activeEntry.spec.durationMs <= 0
        ? 1.0
        : (targetTime - activeEntry.startMs) / activeEntry.spec.durationMs;
    final normalizedEntryProgress = _normalizedProgress(
      activeEntry,
      rawProgress,
    );
    final normalizedTime =
        activeEntry.startMs +
        normalizedEntryProgress * activeEntry.spec.durationMs;
    if (duration <= 0) {
      return normalizedEntryProgress;
    }
    var ratio = (normalizedTime / duration).clamp(0.0, 1.0);
    final allowedLead = (orchestrator.timelineValue + _kMaxLead).clamp(
      0.0,
      1.0,
    );
    if (ratio > allowedLead) {
      ratio = allowedLead;
    }
    return ratio;
  }

  double _normalizedProgress(MotionTimelineEntry entry, double rawProgress) {
    final progress = rawProgress.clamp(0.0, 1.0);
    final previous = _lastNormalizedProgress[entry.spec.id] ?? 0.0;
    final micro = previous * 0.05 + progress * 0.95;
    final dampened = micro.clamp(0.0, 1.0);
    _lastNormalizedProgress[entry.spec.id] = dampened;
    const endZone = 0.12;
    final normalizedTail = dampened > 1 - endZone
        ? (1 - endZone) + ((dampened - (1 - endZone)) / endZone) * endZone
        : dampened;
    return _ease(normalizedTail);
  }

  double _ease(double t) {
    if (t < 0.5) {
      return 4.0 * t * t * t;
    }
    final u = (t - 0.5) * 2.0;
    return 0.5 + 0.5 * (1 - math.pow(1 - u, 3));
  }
}
