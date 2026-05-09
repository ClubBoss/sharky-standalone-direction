import 'simulation_motion_events.dart';
import 'simulation_motion_timing_sequencer.dart';

class MotionStateEntry {
  const MotionStateEntry(this.index, this.atMs, this.event);

  final int index;
  final int atMs;
  final MotionEvent event;
}

class MotionStateStream {
  MotionStateStream(this.sequencer);

  final SimulationMotionTimingSequencer sequencer;

  List<MotionStateEntry> buildStateStream() {
    final timeline = sequencer.buildTimeline();
    return timeline
        .map(
          (entry) =>
              MotionStateEntry(entry.index, entry.atMs, entry.event.event),
        )
        .toList();
  }
}
