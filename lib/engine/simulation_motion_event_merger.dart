import 'simulation_motion_events.dart';

class SimulationMotionEventMerger {
  SimulationMotionEventMerger(this.events);

  final SimulationMotionEvents events;

  List<MotionEvent> buildUnifiedSequence() {
    final dealing = events.buildDealingEvents();
    final chip = events.buildChipTravelEvents();
    final gesture = events.buildGestureEvents();
    return [...dealing, ...chip, ...gesture];
  }
}
