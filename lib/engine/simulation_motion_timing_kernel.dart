import 'simulation_motion_event_merger.dart';
import 'simulation_motion_events.dart';

class TimedMotionEvent {
  const TimedMotionEvent(this.event, this.ms);

  final MotionEvent event;
  final int ms;
}

class SimulationMotionTimingKernel {
  SimulationMotionTimingKernel(this.merger);

  final SimulationMotionEventMerger merger;

  List<TimedMotionEvent> buildTimedSequence() {
    final unified = merger.buildUnifiedSequence();
    return unified.map((event) => TimedMotionEvent(event, 300)).toList();
  }
}
