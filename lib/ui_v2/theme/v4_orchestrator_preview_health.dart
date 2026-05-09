import 'v4_runtime_context.dart';

class V4OrchestratorPreviewHealth {
  const V4OrchestratorPreviewHealth();

  static Map<String, Object?> check(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "ok_colors": readiness["struct_colors"] != null,
      "ok_typography": readiness["struct_typography"] != null,
      "ok_spacing": readiness["struct_spacing"] != null,
      "ok_motion": runtime["motion"] != null,
      "ok_elevation": runtime["elevation"] != null,
    };
  }
}
