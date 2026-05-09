import 'v4_runtime_context.dart';

class V4OrchestratorCohesionIntake {
  const V4OrchestratorCohesionIntake();

  static Map<String, Object?> check(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "cohesion_typography": readiness["struct_typography"] != null,
      "cohesion_colors": readiness["struct_colors"] != null,
      "cohesion_spacing": readiness["struct_spacing"] != null,
      "cohesion_motion": runtime["motion"] != null,
      "cohesion_elevation": runtime["elevation"] != null,
    };
  }
}
