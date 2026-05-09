import 'v4_runtime_context.dart';

class V4OrchestratorPreviewRouting {
  const V4OrchestratorPreviewRouting();

  static Map<String, Object?> plan(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "preview_color_scheme":
          readiness["struct_colors"] != null && runtime["primary"] != null,
      "preview_typography": readiness["struct_typography"] != null,
      "preview_spacing": readiness["struct_spacing"] != null,
      "preview_motion": runtime["motion"] != null,
      "preview_elevation": runtime["elevation"] != null,
    };
  }
}
