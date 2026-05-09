import 'v4_runtime_context.dart';

class V4OrchestratorBehavioralIntake {
  const V4OrchestratorBehavioralIntake();

  static Map<String, Object?> intake(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final global = ctx.global;
    final readiness = ctx.readiness;

    return {
      "present": true,
      "can_apply_v4": (global["is_active"] == true) && readiness.isNotEmpty,
      "should_surface_v4":
          readiness["struct_colors"] != null &&
          readiness["struct_typography"] != null,
      "runtime_health_ok": global.keys.isNotEmpty && readiness.keys.isNotEmpty,
    };
  }
}
