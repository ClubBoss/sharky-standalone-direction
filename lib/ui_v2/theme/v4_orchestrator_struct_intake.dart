import 'v4_runtime_context.dart';

class V4OrchestratorStructIntake {
  const V4OrchestratorStructIntake();

  static Map<String, Object?> intake(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;
    final global = ctx.global;

    return {
      "present": true,
      "color_primary": runtime["primary"],
      "color_secondary": runtime["secondary"],
      "elevation": runtime["elevation"] ?? 0,
      "motion_curve": runtime["motion"] ?? "unknown",
      "scale_body": readiness["struct_typography_scale_body"],
      "scale_title": readiness["struct_typography_scale_title"],
      "v4_ready": global["is_active"] ?? false,
    };
  }
}
