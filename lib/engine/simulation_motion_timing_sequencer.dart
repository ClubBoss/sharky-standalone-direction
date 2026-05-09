import 'simulation_motion_timing_kernel.dart';

class MotionTimelineEntry {
  const MotionTimelineEntry(this.index, this.atMs, this.event);

  final int index;
  final int atMs;
  final TimedMotionEvent event;
}

class SimulationMotionTimingSequencer {
  SimulationMotionTimingSequencer(this.kernel);

  final SimulationMotionTimingKernel kernel;

  List<MotionTimelineEntry> buildTimeline() {
    final timed = kernel.buildTimedSequence();
    final entries = <MotionTimelineEntry>[];
    var accumulator = 0;
    for (var i = 0; i < timed.length; i++) {
      accumulator += timed[i].ms;
      entries.add(MotionTimelineEntry(i, accumulator, timed[i]));
    }
    return entries;
  }
}
