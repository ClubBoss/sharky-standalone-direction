import 'simulation_motion_resolver.dart';

class MotionEvent {
  const MotionEvent(this.kind, this.value);

  final String kind;
  final String value;
}

class SimulationMotionEvents {
  SimulationMotionEvents(this.resolver);

  final SimulationMotionResolver resolver;

  List<MotionEvent> buildDealingEvents() => resolver
      .resolveDealing()
      .map((value) => MotionEvent('dealing', value))
      .toList();

  List<MotionEvent> buildChipTravelEvents() => resolver
      .resolveChipTravel()
      .map((value) => MotionEvent('chip', value))
      .toList();

  List<MotionEvent> buildGestureEvents() => resolver
      .resolveGestures()
      .map((value) => MotionEvent('gesture', value))
      .toList();
}
