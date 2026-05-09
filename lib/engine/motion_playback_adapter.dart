import 'dart:math' as math;

import 'motion_timeline_assembler.dart';

class MotionPlaybackSample {
  const MotionPlaybackSample({
    required this.x,
    required this.y,
    required this.progress,
  });

  final double x;
  final double y;
  final double progress;
}

class MotionPlaybackAdapter {
  MotionPlaybackAdapter(this.input);

  final MotionOrchestratorInput input;
  final Map<String, double> _lastProgress = {};
  final Map<String, double> _lastTemporalProgress = {};
  double _lastBeat = 0.0;

  double get lastBeat => _lastBeat;

  MotionPlaybackSample? sample(String id, double timeMs) {
    for (final entry in input.timeline) {
      if (entry.spec.id != id) {
        continue;
      }
      final duration = entry.spec.durationMs;
      if (timeMs < entry.startMs || timeMs >= entry.startMs + duration) {
        continue;
      }
      final localTime = (timeMs - entry.startMs).clamp(0.0, duration);
      final progress0 = duration == 0 ? 1.0 : localTime / duration;
      final prev = _lastProgress[entry.spec.id] ?? 0.0;
      final progress = _stabilize(prev, progress0.clamp(0.0, 1.0));
      _lastProgress[entry.spec.id] = progress;
      final from = entry.spec.from;
      final to = entry.spec.to;
      final dx = to.dx - from.dx;
      final dy = to.dy - from.dy;
      final base = _channelProgress(timeMs, entry);
      double adjusted = base;
      if (entry.spec.id.startsWith('pot:winner')) {
        adjusted = base + 0.08;
      } else if (entry.spec.id.startsWith('board:') ||
          entry.spec.id.startsWith('seat:card')) {
        adjusted = base - 0.05;
      }
      adjusted = adjusted.clamp(0.0, 1.0);
      final prevTemporal = _lastTemporalProgress[entry.spec.id] ?? 0.0;
      const maxDelta = 0.10;
      final stable = prevTemporal + maxDelta;
      final temporal = adjusted > stable ? stable : adjusted;
      final clampedTemporal = temporal.clamp(0.0, 1.0);
      final microTarget = prevTemporal * 0.05 + clampedTemporal * 0.95;
      final delta = (microTarget - prevTemporal).clamp(-0.07, 0.07);
      final channelProgress = (prevTemporal + delta).clamp(0.0, 1.0);
      _lastTemporalProgress[entry.spec.id] = channelProgress;
      _lastBeat = channelProgress;
      final windowAnchor = entry.startMs + channelProgress * duration;
      final eased = _ease(channelProgress);
      var x = from.dx + dx * eased;
      var y = from.dy + dy * eased;
      final burstT = _windowProgress(windowAnchor, entry.burstWindow);
      if (entry.spec.burstFactor > 1 && burstT > 0) {
        final multiplier = (entry.spec.burstFactor - 1) * burstT;
        x += dx * multiplier;
        y += dy * multiplier;
      }
      final smoothT = _windowProgress(windowAnchor, entry.smoothWindow);
      if (entry.spec.smoothFactor < 1 && smoothT > 0) {
        final ratio = (1 - entry.spec.smoothFactor) * smoothT;
        x += (to.dx - x) * ratio;
        y += (to.dy - y) * ratio;
      }
      final bloomT = _windowProgress(windowAnchor, entry.bloomWindow);
      if (entry.spec.bloomFactor > 0 && bloomT > 0) {
        y -= 10.0 * bloomT * entry.spec.bloomFactor;
      }
      final flipT = _windowProgress(windowAnchor, entry.flipWindow);
      if (entry.spec.flipFactor > 0 && flipT > 0) {
        final depth = 6 * flipT * entry.spec.flipFactor;
        y -= depth;
      }
      final landed = _exitSoftLand(channelProgress);
      x = from.dx + (x - from.dx) * landed;
      y = from.dy + (y - from.dy) * landed;
      return MotionPlaybackSample(x: x, y: y, progress: channelProgress);
    }
    return null;
  }
}

double _cohesion(MotionWindow window, double timeMs) {
  if (window.end <= window.start) {
    return timeMs >= window.end ? 1.0 : 0.0;
  }
  if (timeMs <= window.start) {
    return 0.0;
  }
  if (timeMs >= window.end) {
    return 1.0;
  }
  return (timeMs - window.start) / (window.end - window.start);
}

double _windowProgress(double timeMs, MotionWindow window) {
  final base = _cohesion(window, timeMs);
  if (base <= 0.0) return 0.0;
  if (base >= 1.0) return 1.0;
  return _ease(base).clamp(0.0, 1.0);
}

double _channelProgress(double timeMs, MotionTimelineEntry entry) {
  final duration = entry.spec.durationMs;
  if (duration <= 0.0) {
    return 1.0;
  }
  final normalized = ((timeMs - entry.startMs) / duration).clamp(0.0, 1.0);
  return _ease(normalized);
}

double _ease(double t) {
  if (t < 0.5) {
    return 4.0 * t * t * t;
  }
  final u = (t - 0.5) * 2.0;
  return 0.5 + 0.5 * (1 - math.pow(1 - u, 3));
}

double _exitSoftLand(double t) {
  if (t <= 0.82) {
    return t;
  }
  final u = (t - 0.82) / 0.18;
  return 0.82 + 0.18 * math.sqrt(u);
}

double _stabilize(double prevT, double currT) {
  if (currT < prevT) {
    return prevT;
  }
  final dt = currT - prevT;
  if (dt > 0.22) {
    return prevT + 0.22;
  }
  return currT;
}
