import 'v4_runtime_context.dart';

class V4OrchestratorAlignment {
  const V4OrchestratorAlignment();

  static Map<String, Object?> align(V4RuntimeContext? ctx) {
    if (ctx == null) return const {"present": false};

    final readiness = ctx.readiness;
    final runtime = ctx.runtime;

    return {
      "present": true,
      "aligned_colors":
          readiness["struct_colors"] != null && runtime["primary"] != null,
      "aligned_typography":
          readiness["struct_typography_scale_body"] != null &&
          readiness["struct_typography_scale_title"] != null,
      "aligned_spacing": readiness["struct_spacing"] != null,
      "aligned_motion": runtime["motion"] != null,
      "aligned_elevation": runtime["elevation"] != null,
    };
  }
}
