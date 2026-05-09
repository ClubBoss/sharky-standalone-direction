import 'dart:math' as math;

import 'card_motion_spec.dart';

export 'motion_orchestrator_input.dart';

class MotionTimelineEntry {
  const MotionTimelineEntry({
    required this.spec,
    required this.startMs,
    required this.flipStartMs,
    required this.flipEndMs,
  });

  final CardMotionSpec spec;
  final double startMs;
  final double flipStartMs;
  final double flipEndMs;

  MotionWindow get burstWindow =>
      MotionWindow(startMs.toDouble(), startMs + spec.durationMs * 0.15);

  MotionWindow get smoothWindow =>
      MotionWindow(startMs + spec.durationMs * 0.70, startMs + spec.durationMs);

  MotionWindow get bloomWindow =>
      MotionWindow(startMs + spec.durationMs * 0.85, startMs + spec.durationMs);

  MotionWindow get flipWindow => MotionWindow(flipStartMs, flipEndMs);
}

class MotionWindow {
  const MotionWindow(this.start, this.end);

  final double start;
  final double end;
}

List<MotionTimelineEntry> assembleTimeline(List<CardMotionSequence> sequences) {
  final rawEntries = <_RawTimelineEntry>[];
  for (final sequence in sequences) {
    var cumulative = 0.0;
    for (final spec in sequence) {
      cumulative += spec.delayMs;
      final flipDuration = math.min(spec.durationMs * 0.6, 250.0);
      rawEntries.add(
        _RawTimelineEntry(
          spec: spec,
          start: cumulative,
          flipStart: cumulative,
          flipEnd: cumulative + flipDuration,
        ),
      );
    }
  }
  if (rawEntries.isEmpty) {
    return const [];
  }
  final globalStart = rawEntries.map((entry) => entry.start).reduce(math.min);
  final entries = rawEntries
      .map(
        (entry) => MotionTimelineEntry(
          spec: entry.spec,
          startMs: entry.start - globalStart,
          flipStartMs: entry.flipStart - globalStart,
          flipEndMs: entry.flipEnd - globalStart,
        ),
      )
      .toList();
  entries.sort((a, b) => a.startMs.compareTo(b.startMs));
  return entries;
}

class _RawTimelineEntry {
  _RawTimelineEntry({
    required this.spec,
    required this.start,
    required this.flipStart,
    required this.flipEnd,
  });

  final CardMotionSpec spec;
  final double start;
  final double flipStart;
  final double flipEnd;
}
