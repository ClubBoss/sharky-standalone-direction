import 'simulation_motion_blueprint.dart';

class SimulationMotionResolver {
  SimulationMotionResolver(this.blueprint);

  final SimulationMotionBlueprint blueprint;

  List<String> resolveDealing() {
    final bundle = blueprint.buildAll();
    return bundle['dealing'] ?? const [];
  }

  List<String> resolveChipTravel() {
    final bundle = blueprint.buildAll();
    return bundle['chip'] ?? const [];
  }

  List<String> resolveGestures() {
    final bundle = blueprint.buildAll();
    return bundle['gesture'] ?? const [];
  }
}
